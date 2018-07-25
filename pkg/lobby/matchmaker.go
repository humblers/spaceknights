package lobby

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net"
	"net/http"
	"strconv"
	"time"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/game"
)

type MatchMaker struct {
	*Router
	redisPool     *redis.Pool
	matchWaitings map[string]chan game.Config

	logger *log.Logger
}

func MatchRouter(path string, m *http.ServeMux, ss *redistore.RediStore, p *redis.Pool, l *log.Logger) *MatchMaker {
	mm := &MatchMaker{
		Router:        NewRouter(path, m, ss, p, l),
		redisPool:     p,
		matchWaitings: make(map[string]chan game.Config),
		logger:        l,
	}
	mm.Post("/request", mm.Request)
	go mm.run()
	go mm.subscribe()
	return mm
}

func (mm *MatchMaker) run() {
	ticker := time.NewTicker(time.Millisecond * 1000)
	defer ticker.Stop()
	for {
		select {
		case <-ticker.C:
			mm.MatchMaking()
		}
	}
}

func (mm *MatchMaker) subscribe() {
	rc := mm.redisPool.Get()
	defer rc.Close()

	rc.Send("SUBSCRIBE", "match")
	rc.Flush()
	_, err := rc.Receive() // ignore first receive
	if err != nil {
		panic(err)
	}
	for {
		reply, err := redis.Values(rc.Receive())
		if err != nil {
			panic(err)
		}
		if len(reply) > 2 && string(reply[0].([]byte)) == "message" && string(reply[1].([]byte)) == "match" {
			mm.logger.Printf("[SUBSCRIBE] %v", string(reply[2].([]byte)))
			var cfg game.Config
			if err := json.Unmarshal(reply[2].([]byte), &cfg); err != nil {
				mm.logger.Print(err)
				continue
			}
			for _, player := range cfg.Players {
				if ch, ok := mm.matchWaitings[player.Id]; ok {
					ch <- cfg
				}
			}
		}
	}
}

func (mm *MatchMaker) MatchMaking() {
	rval := make([]byte, 20)
	if _, err := rand.Read(rval); err != nil {
		return
	}

	c := mm.redisPool.Get()
	defer c.Close()

	closure, err := lock(c, "match:lock", rval, time.Second*2)
	if err != nil {
		mm.logger.Printf("error locking(%v)", err)
		return
	}
	defer func() {
		if err := closure(); err != nil {
			mm.logger.Printf("error unlocking(%v)", err)
		}
	}()

	waitings, err := redis.Values(c.Do("ZRANGE", "match:waitings", 0, -1, "WITHSCORES"))
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
		cnt, err := redis.Int(c.Do("ZREM", "match:waitings", uid1, uid2))
		if err != nil {
			panic(err)
		}
		if cnt != 2 {
			panic(fmt.Errorf("expect count == 2, actual num: %v", cnt))
		}
		go mm.MatchNotice(uid1, uid2, regTime1, regTime2)
	}
}

func (mm *MatchMaker) MatchNotice(uid1, uid2 string, regTime1, regTime2 int) {
	rc := mm.redisPool.Get()
	defer rc.Close()

	var err error
	defer func() {
		if err != nil {
			mm.logger.Printf("rollback waitings: %v", err)
			if _, err := rc.Do("ZADD", "match:waitings", regTime1, uid1, regTime2, uid2); err != nil {
				mm.logger.Printf("rollback waitings fail: %v", err)
			}
		}
	}()

	config := game.Config{
		MapName: "Thanatos",
	}
	blue, err := mm.getPlayerData(rc, uid1, "Blue")
	if err != nil {
		return
	}
	config.Players = append(config.Players, blue)
	red, err := mm.getPlayerData(rc, uid2, "Red")
	if err != nil {
		return
	}
	config.Players = append(config.Players, red)
	sid, err := redis.Int(rc.Do("INCR", "gen:session"))
	if err != nil {
		return
	}
	config.Id = strconv.Itoa(sid)

	conn, err := net.DialTimeout("tcp", ":9989", time.Second*5)
	if err != nil {
		return
	}
	defer conn.Close()
	packet, err := json.Marshal(config)
	if err != nil {
		return
	}
	packet = append(packet, '\n')
	_, err = conn.Write(packet)
	if err != nil {
		return
	}
	if err = conn.SetReadDeadline(time.Now().Add(time.Second * 5)); err != nil {
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
	_, err = rc.Do("PUBLISH", "match", packet)
}

func (mm *MatchMaker) Request(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp MatchResponse
	b.response = &resp

	c := b.redisConn
	if _, err := c.Do("ZADD", "match:waitings", "NX", time.Now().Unix(), b.uid); err != nil {
		resp.ErrMessage = "match fail"
		return
	}
	mm.logger.Printf("[MATCH] requested")
	mm.matchWaitings[b.uid] = make(chan game.Config)
	resp.Config = <-mm.matchWaitings[b.uid]
	resp.Address = "13.125.74.237"
	mm.logger.Printf("[MATCH] created")
}

func (m *MatchMaker) getPlayerData(rc redis.Conn, uid, team string) (game.PlayerData, error) {
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
			data.Deck = append(data.Deck, game.Card{Name: units[knight]["active"].(string), Level: card.Level})
		}
		data.Knights = append(data.Knights, game.KnightData{Name: knight, Level: card.Level})
	}
	return data, nil
}
