package main

import "sync"
import "log"
import "time"
import "flag"
import "net"
import "os"
import "os/signal"
import "bufio"
import "encoding/json"
import "runtime"
import "runtime/pprof"

import "github.com/gomodule/redigo/redis"
import "github.com/humblers/spaceknights/pkg/game"

const clientTimeout = time.Minute

type Notification struct {
	GameCreated *game.Config
	// add another notification types here
}

var logger *log.Logger
var pool *redis.Pool

var mutex sync.RWMutex
var clients map[string]net.Conn = make(map[string]net.Conn)
var wg sync.WaitGroup
var numGR int // # of goroutines for leak detection

func main() {
	var port, rhost, rport string
	flag.StringVar(&port, "port", "9998", "listen port")
	flag.StringVar(&rhost, "rhost", "127.0.0.1", "redis server host")
	flag.StringVar(&rport, "rport", "6379", "redis server port")
	flag.Parse()

	logger = log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)
	pool = &redis.Pool{
		Dial:        func() (redis.Conn, error) { return redis.Dial("tcp", net.JoinHostPort(rhost, rport)) },
		MaxIdle:     3,
		IdleTimeout: 240 * time.Second,
	}
	defer pool.Close()
	logger.Println("server starting")
	numGR = runtime.NumGoroutine()

	// listen clients
	addr, err := net.ResolveTCPAddr("tcp", net.JoinHostPort("", port))
	if err != nil {
		panic(err)
	}
	listener, err := net.ListenTCP("tcp", addr)
	if err != nil {
		panic(err)
	}
	wg.Add(1)
	go func() {
		defer wg.Done()
		defer listener.Close()
		for {
			if conn, err := listener.Accept(); err != nil {
				if e, ok := err.(net.Error); ok && e.Timeout() {
					break
				}
				panic(err)
			} else {
				wg.Add(1)
				go func() {
					defer wg.Done()
					defer conn.Close()
					// auth
					if err := conn.SetReadDeadline(time.Now().Add(1 * time.Second)); err != nil {
						logger.Print(err)
						return
					}
					reader := bufio.NewReader(conn)
					b, err := reader.ReadBytes('\n')
					if err != nil {
						logger.Print(err)
						return
					}
					var auth game.Auth
					if err := json.Unmarshal(b, &auth); err != nil {
						logger.Print(err)
						return
					}
					if auth.Id != auth.Token { // TODO: implement auth using humbler token
						logger.Print("auth failed")
						return
					}
					id := auth.Id
					mutex.Lock()
					if existing := clients[id]; existing != nil {
						existing.SetReadDeadline(time.Now())
					}
					clients[id] = conn
					mutex.Unlock()
					logger.Printf("user %v connected", id)
					for {
						if err := conn.SetReadDeadline(time.Now().Add(clientTimeout)); err != nil {
							panic(err)
						}
						if _, err := reader.ReadBytes('\n'); err != nil {
							// timeout or whatever errors
							logger.Print(err)
							mutex.Lock()
							delete(clients, id)
							mutex.Unlock()
							logger.Printf("user %v disconnected", id)
							break
						} else {
							// client heartbeat: no-op
						}
					}
				}()
			}
		}
	}()

	// subscribe to matchmaking channel
	conn := pool.Get()
	defer conn.Close()
	psc := redis.PubSubConn{Conn: conn}
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := psc.Subscribe("match"); err != nil {
			panic(err)
		}
		for {
			switch v := psc.Receive().(type) {
			case redis.Message:
				var cfg game.Config
				if err := json.Unmarshal(v.Data, &cfg); err != nil {
					panic(err)
				}
				logger.Printf("game created: %v vs %v", cfg.Players[0].Id, cfg.Players[1].Id)
				for _, p := range cfg.Players {
					mutex.RLock()
					c := clients[p.Id]
					mutex.RUnlock()
					if c != nil {
						noti := Notification{GameCreated: &cfg}
						packet, err := json.Marshal(noti)
						if err != nil {
							panic(err)
						}
						packet = append(packet, '\n')
						c.Write(packet)
					}
				}
			case redis.Subscription:
				if v.Kind == "unsubscribe" {
					return
				}
			case error:
				panic(v)
			}
		}
	}()

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt)
	sig := <-c
	logger.Printf("Got %v signal. Aborting...", sig)

	// stop listening
	if err := listener.SetDeadline(time.Now()); err != nil {
		panic(err)
	}

	// stop all clients
	mutex.RLock()
	for _, c := range clients {
		c.SetReadDeadline(time.Now())
	}
	mutex.RUnlock()

	// stop subscribing
	if err := psc.Unsubscribe(); err != nil {
		panic(err)
	}
	wg.Wait()
	curr := runtime.NumGoroutine()
	if curr != numGR {
		logger.Printf("go routine leak detected: %v -> %v", numGR, curr)
		pprof.Lookup("goroutine").WriteTo(os.Stderr, 2)
	}
	logger.Println("server stopped")
}
