package main

import "fmt"
import "sync"
import "log"
import "time"
import "flag"
import "net"
import "os"
import "os/signal"
import "bufio"
import "encoding/json"

import "github.com/gomodule/redigo/redis"
import "github.com/humblers/spaceknights/pkg/game"

const clientTimeout = time.Minute

var logger *log.Logger
var pool *redis.Pool

var mutex sync.RWMutex
var clients map[string]net.Conn
var wg sync.WaitGroup

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
				reader := bufio.NewReader(conn)
				// auth
				if err := conn.SetReadDeadline(time.Now().Add(1 * time.Second)); err != nil {
					logger.Print(err)
					break
				}
				b, err := reader.ReadBytes('\n')
				if err != nil {
					logger.Print(err)
					break
				}
				var auth game.Auth
				if err := json.Unmarshal(b, &auth); err != nil {
					logger.Print(err)
					break
				}
				if auth.Id != auth.Token { // TODO: implement auth using humbler token
					logger.Print("auth failed")
					break
				}
				id := auth.Id
				mutex.Lock()
				if existing := clients[id]; existing != nil {
					existing.SetReadDeadline(time.Now())
				}
				clients[id] = conn
				mutex.Unlock()

				wg.Add(1)
				go func() {
					defer wg.Done()
					defer conn.Close()
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
				for _, p := range cfg.Players {
					mutex.RLock()
					c := clients[p.Id]
					mutex.RUnlock()
					if c != nil {
						c.Write(v.Data)
					}
				}
			case redis.Subscription:
				if v.Kind == "unsubscribe" {
					break
				}
			case error:
				panic(v)
			}
		}
	}()

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt)
	select {
	case sig := <-c:
		fmt.Fprintln(os.Stderr, "")
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
	}
}
