package lobby

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/game"
)

type MatchMaker interface {
	http.Handler
	Stop()
}

type matchMaker struct {
	*Router

	cancelFunc    context.CancelFunc
	cancelWait    sync.WaitGroup
	mu            sync.Mutex
	matchWaitings map[string]chan MatchResponse

	redisPool *redis.Pool
	logger    *log.Logger
}

func NewMatchMaker(path string, ss *redistore.RediStore, p *redis.Pool, l *log.Logger) (string, MatchMaker) {
	mm := &matchMaker{
		Router: &Router{
			path:         path,
			sessionStore: ss,
			redisPool:    p,
			logger:       l,
		},
		redisPool:     p,
		matchWaitings: make(map[string]chan MatchResponse),
		logger:        l,
	}
	mm.Post("request", mm.request)
	ctx, cancel := context.WithCancel(context.Background())
	mm.cancelFunc = cancel
	go mm.run(ctx)
	go mm.subscribe(ctx)
	return path, mm
}

func (mm *matchMaker) Stop() {
	mm.cancelFunc()
	mm.cancelWait.Wait()

	args := redis.Args{"match:waitings"}
	mm.mu.Lock()
	for k, v := range mm.matchWaitings {
		v <- MatchResponse{ErrMessage: "match request fail"}
		delete(mm.matchWaitings, k)
		args = args.Add(k)
	}
	mm.mu.Unlock()

	rc := mm.redisPool.Get()
	defer rc.Close()
	if closure, err := lockKey(rc, "match:lock", 2*time.Second); err != nil {
		mm.logger.Printf("[MATCH] db lock failed on shutdown: %v", err)
	} else {
		defer closure()
	}
	rc.Do("ZREM", args)
}

func (mm *matchMaker) run(ctx context.Context) {
	mm.cancelWait.Add(1)
	defer mm.cancelWait.Done()

	ticker := time.NewTicker(1000 * time.Millisecond)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			mm.matchMaking(ctx)
		case <-ctx.Done():
			return
		}
	}
}

func (mm *matchMaker) subscribe(ctx context.Context) {
	rc := mm.redisPool.Get()
	rc.Send("SUBSCRIBE", "match")
	rc.Flush()
	defer func() {
		rc.Send("UNSUBSCRIBE", "match")
		rc.Flush()
		rc.Close()
	}()

	go func() {
		mm.cancelWait.Add(1)
		defer mm.cancelWait.Done()
		for {
			reply, err := redis.Values(rc.Receive())
			if err != nil {
				if err.Error() == "redigo: connection closed" {
					return
				}
				panic(err)
			}
			if len(reply) > 2 && string(reply[0].([]byte)) == "message" && string(reply[1].([]byte)) == "match" {
				var cfg game.Config
				if err := json.Unmarshal(reply[2].([]byte), &cfg); err != nil {
					mm.logger.Print(err)
					continue
				}
				mm.mu.Lock()
				for _, player := range cfg.Players {
					if ch, ok := mm.matchWaitings[player.Id]; ok {
						ch <- MatchResponse{Config: cfg}
						delete(mm.matchWaitings, player.Id)
					}
				}
				mm.mu.Unlock()
			}
		}
	}()
	<-ctx.Done()
}

func (mm *matchMaker) publish(message []byte) {
	rc := mm.redisPool.Get()
	defer rc.Close()
	if _, err := rc.Do("PUBLISH", "match", message); err != nil {
		panic(err)
	}
}

func (mm *matchMaker) matchMaking(ctx context.Context) {
	rc := mm.redisPool.Get()
	defer rc.Close()

	closure, err := lockKey(rc, "match:lock", 2*time.Second)
	if err != nil {
		mm.logger.Printf("error locking(%v)", err)
		return
	}
	defer func() {
		if err := closure(); err != nil {
			mm.logger.Printf("error unlocking(%v)", err)
		}
	}()

	waitings, err := redis.Values(rc.Do("ZRANGE", "match:waitings", 0, -1, "WITHSCORES"))
	if err != nil {
		return
	}
	// TODO: add matching rule
	// score means match registration time
	for {
		var uid1, uid2 string
		var regTime1, regTime2 int
		waitings, err = redis.Scan(waitings, &uid1, &regTime1, &uid2, &regTime2)
		if err != nil {
			break
		}
		cnt, err := redis.Int(rc.Do("ZREM", "match:waitings", uid1, uid2))
		if err != nil {
			panic(err)
		}
		if cnt != 2 {
			mm.logger.Printf("expect count == 2, actual num: %v", cnt)
			continue
		}
		go mm.createMatchConfig(ctx, uid1, uid2, regTime1, regTime2)
	}
}

func (mm *matchMaker) createMatchConfig(ctx context.Context, uid1, uid2 string, regTime1, regTime2 int) {
	rc := mm.redisPool.Get()
	defer rc.Close()

	go func() {
		mm.cancelWait.Add(1)
		defer mm.cancelWait.Done()

		var err error
		defer func() {
			if err != nil {
				mm.logger.Printf("rollback waitings: %v", err)
				// get new connection. because already closed by cancel context
				c := mm.redisPool.Get()
				defer c.Close()
				if _, err := c.Do("ZADD", "match:waitings", regTime1, uid1, regTime2, uid2); err != nil {
					mm.logger.Printf("rollback waitings fail: %v", err)
				}
			}
		}()

		config := game.Config{
			MapName: "Thanatos",
		}
		var blue game.PlayerData
		blue, err = mm.getPlayerData(rc, uid1, "Blue")
		if err != nil {
			return
		}
		config.Players = append(config.Players, blue)
		var red game.PlayerData
		red, err = mm.getPlayerData(rc, uid2, "Red")
		if err != nil {
			return
		}
		config.Players = append(config.Players, red)
		var sid int
		sid, err = redis.Int(rc.Do("INCR", "gen:session"))
		if err != nil {
			return
		}
		config.Id = strconv.Itoa(sid)

		var conn net.Conn
		conn, err = net.DialTimeout("tcp", ":9989", 1*time.Second)
		if err != nil {
			return
		}
		defer conn.Close()
		var packet []byte
		packet, err = json.Marshal(config)
		if err != nil {
			return
		}
		_, err = conn.Write(append(packet, '\n'))
		if err != nil {
			return
		}
		if err = conn.SetReadDeadline(time.Now().Add(1 * time.Second)); err != nil {
			return
		}
		reader := bufio.NewReader(conn)
		b, err := reader.ReadBytes('\n')
		if err != nil {
			return
		}
		var resp game.LobbyResponse
		if err = json.Unmarshal(b, &resp); err != nil {
			return
		}
		if !resp.Created {
			err = fmt.Errorf("game server can't create game session")
			return
		}
		mm.publish(packet)

	}()
	<-ctx.Done()
}

func (mm *matchMaker) request(b *bases, w http.ResponseWriter, r *http.Request) {
	c := b.redisConn
	if _, err := c.Do("ZADD", "match:waitings", "NX", time.Now().Unix(), b.uid); err != nil {
		b.response = &MatchResponse{ErrMessage: "match request fail"}
		return
	}

	ch := make(chan MatchResponse)
	mm.mu.Lock()
	mm.matchWaitings[b.uid] = ch
	mm.mu.Unlock()

	select {
	case resp := <-ch:
		b.response = &resp
		if resp.ErrMessage == "" {
			resp.Address = "13.125.74.237"
			mm.logger.Printf("[MATCH] created server ip: %v", resp.Address)
		}
	case <-r.Context().Done():
		b.response = &MatchResponse{ErrMessage: "match request fail"}
	}
}

func (m *matchMaker) getPlayerData(rc redis.Conn, uid, team string) (game.PlayerData, error) {
	data := game.PlayerData{
		Id:   uid,
		Team: game.Team(team),
	}
	index, err := redis.Int(rc.Do("GET", fmt.Sprintf("%v:decknum", uid)))
	if err != nil {
		return data, err
	}
	deck_raw, err := redis.Bytes(rc.Do("LINDEX", fmt.Sprintf("%v:decks", uid), index))
	if err != nil {
		return data, err
	}
	var deck deck
	if err := json.Unmarshal(deck_raw, &deck); err != nil {
		return data, err
	}
	args := redis.Args{fmt.Sprintf("%v:cards", uid)}.AddFlat(deck.Troops).AddFlat(deck.Knights)
	reply, err := redis.Values(rc.Do("HMGET", args...))
	if err != nil {
		return data, err
	}
	for i, troop := range deck.Troops {
		var card userCard
		if err := json.Unmarshal(reply[i].([]byte), &card); err != nil {
			return data, err
		}
		data.Deck = append(data.Deck, game.Card{Name: troop, Level: card.Level})
	}
	for i, knight := range deck.Knights {
		var card userCard
		if err := json.Unmarshal(reply[len(deck.Troops)+i].([]byte), &card); err != nil {
			return data, err
		}
		if i != 0 {
			data.Deck = append(data.Deck, game.Card{Name: knight, Level: card.Level})
		}
		data.Knights = append(data.Knights, game.KnightData{Name: knight, Level: card.Level})
	}
	return data, nil
}
