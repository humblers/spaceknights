package game

import "os"
import "net"
import "log"
import "time"
import "sync"
import "bufio"
import "runtime"
import "runtime/pprof"

import "git.humbler.games/spaceknights/spaceknights/pkg/nav"

type Server interface {
	Run()
	Stop()
}

type server struct {
	sync.RWMutex
	games map[string]*game
	_map  nav.Map

	caddr     string
	laddr     string
	clistener *net.TCPListener
	llistener *net.TCPListener

	cwg sync.WaitGroup
	lwg sync.WaitGroup
	gwg sync.WaitGroup

	logger *log.Logger

	numGR int // # of goroutine for leak detection
}

func NewServer(caddr, laddr string, logger *log.Logger) Server {
	return &server{
		games: make(map[string]*game),
		_map:  nav.NewThanatos(params["scale"]),

		caddr:  caddr,
		laddr:  laddr,
		logger: logger,
	}
}

func (s *server) Run() {
	s.logger.Print("server starting")
	s.numGR = runtime.NumGoroutine()
	s.listenClients()
	s.listenLobby()

	// temporary for debugging
	s.runGame(GameConfig{
		Id: "BEEF",
		Players: []Player{
			Player{"Alice"},
			Player{"Bob"},
		},
	})
}

func (s *server) listenClients() {
	addr, err := net.ResolveTCPAddr("tcp", s.caddr)
	if err != nil {
		panic(err)
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
					c.run()
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
					var req LobbyRequest
					if err := packet(b).parse(&req); err != nil {
						panic(err)
					}
					var exists bool
					if s.findGame(req.SessionId) != nil {
						exists = true
					}
					resp := LobbyResponse{
						Exists: exists,
					}
					if exists || req.DoNotCreate {
						if _, err := conn.Write(newPacket(resp)); err != nil {
							panic(err)
						}
						return
					}
					s.runGame(GameConfig{
						Id: req.SessionId,
						Players: []Player{
							Player{"Alice"},
							Player{"Bob"},
						},
					})
					resp.Created = true
					if _, err := conn.Write(newPacket(resp)); err != nil {
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

func (s *server) findGame(id string) *game {
	s.RLock()
	game := s.games[id]
	s.RUnlock()
	return game
}

func (s *server) runGame(cfg GameConfig) {
	g := newGame(s._map, cfg.Players, s.logger)
	s.gwg.Add(1)
	go func() {
		defer s.gwg.Done()
		defer s.logger.Printf("%v stopped", g)
		defer s.removeGame(cfg.Id)
		s.logger.Printf("%v starting", g)
		g.run()
	}()
	s.Lock()
	s.games[cfg.Id] = g
	s.Unlock()
}

func (s *server) removeGame(id string) {
	s.Lock()
	delete(s.games, id)
	s.Unlock()
}
