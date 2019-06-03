package game

import "os"
import "fmt"
import "net"
import "log"
import "time"
import "sync"
import "bufio"
import "runtime"
import "runtime/pprof"
import "encoding/json"

import "github.com/gomodule/redigo/redis"
import "github.com/humblers/spaceknights/pkg/data"

type Server interface {
	Run()
	Stop()
}

type server struct {
	sync.RWMutex
	games map[string]Game

	caddr string
	laddr string

	// server use TCPListener instead of generic Listener
	// to use SetDeadline method
	// SetDeadline is required to distinguish stop signal from unexpected error
	clistener *net.TCPListener
	llistener *net.TCPListener

	cwg sync.WaitGroup
	lwg sync.WaitGroup
	gwg sync.WaitGroup

	logger *log.Logger

	numGR int // # of goroutines for leak detection

	redisPool *redis.Pool // for replay save
}

func NewServer(caddr, laddr string, logger *log.Logger) Server {
	return &server{
		games: make(map[string]Game),

		caddr:  caddr,
		laddr:  laddr,
		logger: logger,

		redisPool: &redis.Pool{
			Dial: func() (redis.Conn, error) {
				return redis.Dial("tcp", ":6379")
			},
			MaxIdle:     3,
			IdleTimeout: 240 * time.Second,
		},
	}
}

func (s *server) Run() {
	s.logger.Print("server starting")
	s.numGR = runtime.NumGoroutine()
	s.listenClients()
	s.listenLobby()
}

func (s *server) listenClients() {
	addr, err := net.ResolveTCPAddr("tcp", s.caddr)
	if err != nil {
		panic(err)
	}
	if addr.IP.String() != "127.0.0.1" {
		//AWS EC2 public address can't binding(VM)
		addr.IP = nil
	}
	listener, err := net.ListenTCP("tcp", addr)
	if err != nil {
		panic(err)
	}
	s.clistener = listener

	s.cwg.Add(1)
	go func() {
		defer s.cwg.Done()
		defer s.closeListener(s.clistener)
		for {
			if conn, err := s.clistener.Accept(); err != nil {
				if e, ok := err.(net.Error); ok && e.Timeout() {
					break
				}
				panic(err)
			} else {
				s.cwg.Add(1)
				go func() {
					defer s.cwg.Done()
					c := newClient(conn, s, s.logger)
					c.Run()
				}()
			}
		}
	}()

}

func (s *server) listenLobby() {
	addr, err := net.ResolveTCPAddr("tcp", s.laddr)
	if err != nil {
		panic(err)
	}
	listener, err := net.ListenTCP("tcp", addr)
	if err != nil {
		panic(err)
	}
	s.llistener = listener

	s.lwg.Add(1)
	go func() {
		defer s.lwg.Done()
		defer s.closeListener(s.llistener)
		for {
			if conn, err := s.llistener.Accept(); err != nil {
				if e, ok := err.(net.Error); ok && e.Timeout() {
					break
				}
				panic(err)
			} else {
				s.lwg.Add(1)
				go func() {
					defer s.lwg.Done()
					defer func() {
						if err := conn.Close(); err != nil {
							panic(err)
						}
					}()
					if err := conn.SetReadDeadline(time.Now().Add(1 * time.Second)); err != nil {
						panic(err)
					}
					reader := bufio.NewReader(conn)
					b, err := reader.ReadBytes('\n')
					if err != nil {
						panic(err)
					}
					var cfg Config
					if err := packet(b).parse(&cfg); err != nil {
						panic(err)
					}
					cfg.Address = s.caddr
					s.runGame(cfg)
				}()
			}
		}
	}()
}

func (s *server) closeListener(l *net.TCPListener) {
	if err := l.Close(); err != nil {
		panic(err)
	}
}

func (s *server) Stop() {
	// prevent game creation
	if err := s.llistener.SetDeadline(time.Now()); err != nil {
		panic(err)
	}
	s.lwg.Wait()

	// wait clients
	if err := s.clistener.SetDeadline(time.Now()); err != nil {
		panic(err)
	}
	s.cwg.Wait()

	// wait running games
	s.gwg.Wait()

	curr := runtime.NumGoroutine()
	if curr != s.numGR {
		s.logger.Printf("go routine leak detected: %v -> %v", s.numGR, curr)
		pprof.Lookup("goroutine").WriteTo(os.Stderr, 2)
	}

	s.logger.Print("server stopped")
}

func (s *server) findGame(id string) Game {
	s.RLock()
	game := s.games[id]
	s.RUnlock()
	return game
}

func (s *server) runGame(cfg Config) {
	g := NewGame(cfg, nil, s.logger)
	s.gwg.Add(1)
	go func() {
		defer s.gwg.Done()
		defer s.saveResult(g)
		defer s.logger.Printf("%v stopped", g)
		defer s.removeGame(g, cfg)
		s.logger.Printf("%v starting", g)
		g.Run()
	}()
	s.Lock()
	s.games[cfg.Id] = g
	s.Unlock()

	// marshal game config
	bytes, err := json.Marshal(cfg)
	if err != nil {
		panic(err)
	}

	// record game config for reconnect
	conn := s.redisPool.Get()
	defer conn.Close()
	key1 := fmt.Sprintf("%v:game", cfg.Players[0].Id)
	key2 := fmt.Sprintf("%v:game", cfg.Players[1].Id)
	if _, err := conn.Do("MSET", key1, bytes, key2, bytes); err != nil {
		panic(err)
	}

	// publish to notifier
	if _, err := conn.Do("PUBLISH", "match", bytes); err != nil {
		panic(err)
	}
}

func (s *server) saveResult(g Game) {
	conn := s.redisPool.Get()
	defer conn.Close()

	// save replay
	replay := g.Replay()
	key := fmt.Sprintf("game:%v", g.Id())
	b, err := json.Marshal(replay)
	if err != nil {
		s.logger.Print(err)
	}
	if _, err := conn.Do("SET", key, string(b)); err != nil {
		s.logger.Printf("cannot save replay: %v", g.Id())
	}

	// apply result
	if replay.Winner == "" { // draw
		return
	}
	for _, p := range replay.Config.Players {
		if p.Id == "bot" {
			continue
		}
		key_rank := fmt.Sprintf("%v:rank", p.Id)
		key_medal := fmt.Sprintf("%v:medal", p.Id)
		key_medal_chest := fmt.Sprintf("%v:medal-chest", p.Id)
		conn.Send("GET", key_rank)
		conn.Send("GET", key_medal)
		conn.Send("GET", key_medal_chest)
		conn.Flush()
		rank, _ := redis.Int(conn.Receive())
		medal, _ := redis.Int(conn.Receive())
		medalChest, _ := redis.Int(conn.Receive())

		if p.Team == replay.Winner {
			if rank > 0 {
				if medal < data.MedalsPerRank {
					medal++
				} else {
					rank--
					medal = 1
				}
			}
			medalChest++
			// chest reward
			key_slots := fmt.Sprintf("%v:battle-chest-slots", p.Id)
			v, _ := conn.Do("LRANGE", key_slots, 0, -1)
			slice := v.([]interface{})
			for i, v := range slice {
				var chest *data.Chest
				json.Unmarshal(v.([]byte), &chest)
				if chest == nil { // empty slot
					key_order := fmt.Sprintf("%v:battle-chest-order", p.Id)
					order, _ := redis.Int(conn.Do("GET", key_order))
					order = order % len(data.ChestOrder)
					name := data.ChestOrder[order]
					time := time.Now().Unix()
					chest := &data.Chest{
						Name:         name,
						AcquiredRank: rank,
						AcquiredAt:   time,
					}
					json, _ := json.Marshal(chest)
					conn.Send("LSET", key_slots, i, json)
					conn.Send("SET", key_order, order+1)
					if _, err := conn.Do(""); err != nil {
						panic(err)
					}
					break
				}
			}
		} else {
			if medal <= 0 {
				if rank%data.RankDownLimit != 0 {
					rank++
					medal = data.MedalsPerRank - 1
				}
			} else {
				medal--
			}
			// chest reward
			key_slots := fmt.Sprintf("%v:feeble-chest-slots", p.Id)
			v, _ := conn.Do("LRANGE", key_slots, 0, -1)
			slice := v.([]interface{})
			for i, v := range slice {
				var chest *data.Chest
				json.Unmarshal(v.([]byte), &chest)
				if chest == nil { // empty slot
					time := time.Now().Unix()
					chest := &data.Chest{
						Name:         "Silver",
						AcquiredRank: rank,
						AcquiredAt:   time,
					}
					json, _ := json.Marshal(chest)
					conn.Send("LSET", key_slots, i, json)
					if _, err := conn.Do(""); err != nil {
						panic(err)
					}
					break
				}
			}

		}
		conn.Send("SET", key_rank, rank)
		conn.Send("SET", key_medal, medal)
		conn.Send("SET", key_medal_chest, medalChest)
		conn.Do("")
	}
}

func (s *server) removeGame(g Game, cfg Config) {
	s.Lock()
	delete(s.games, g.Id())
	s.Unlock()

	// delete game config to prevent reconnect
	conn := s.redisPool.Get()
	defer conn.Close()
	key1 := fmt.Sprintf("%v:game", cfg.Players[0].Id)
	key2 := fmt.Sprintf("%v:game", cfg.Players[1].Id)
	if _, err := conn.Do("DEL", key1, key2); err != nil {
		panic(err)
	}
}
