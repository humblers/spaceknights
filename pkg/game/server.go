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

	numGR int // # of goroutine for leak detection

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
					s.runGame(cfg)
					if _, err := conn.Write(newPacket(LobbyResponse{s.caddr})); err != nil {
						panic(err)
					}
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
		defer s.saveReplay(g)
		defer s.logger.Printf("%v stopped", g)
		defer s.removeGame(g)
		s.logger.Printf("%v starting", g)
		g.Run()
	}()
	s.Lock()
	s.games[cfg.Id] = g
	s.Unlock()
}

func (s *server) saveReplay(g Game) {
	conn := s.redisPool.Get()
	defer conn.Close()
	key := fmt.Sprintf("game:%v", g.Id())
	b, err := json.Marshal(g.Replay())
	if err != nil {
		s.logger.Print(err)
	}
	if _, err := conn.Do("SET", key, string(b)); err != nil {
		s.logger.Printf("cannot save replay: %v", g.Id())
	}
}

func (s *server) removeGame(g Game) {
	s.Lock()
	delete(s.games, g.Id())
	s.Unlock()
}
