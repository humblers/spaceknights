package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
	gcontext "github.com/gorilla/context"
	"github.com/gorilla/securecookie"
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/lobby"
)

func main() {
	data.Initialize()

	// global logger
	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)

	// set redis connection pool
	p := &redis.Pool{
		Dial:        func() (redis.Conn, error) { return redis.Dial("tcp", ":6379") },
		MaxIdle:     3,
		IdleTimeout: 240 * time.Second,
	}
	defer p.Close()

	// redis session store with session key(key get or generate)
	rc := p.Get()
	key := "session:key"
	sk := securecookie.GenerateRandomKey(32)
	if _, err := rc.Do("SETNX", key, sk); err != nil {
		sk, err = redis.Bytes(rc.Do("GET", key))
		if err != nil {
			panic(err)
		}
	}
	ss, err := redistore.NewRediStoreWithPool(p, sk)
	if err != nil {
		panic(err)
	}
	defer ss.Close()
	ss.SetKeyPrefix("session:")
	rc.Close()

	// set http mux for routing
	m := http.NewServeMux()
	m.Handle(lobby.NewAuthRouter("/auth/", ss, p, logger))
	m.Handle(lobby.NewDataRouter("/data/", ss, p, logger))
	m.Handle(lobby.NewEditRouter("/edit/", ss, p, logger))
	path, mm := lobby.NewMatchMaker("/match/", ss, p, logger)
	m.Handle(path, mm)

	// gracefully shutdown http server
	hs := &http.Server{Addr: ":8080", Handler: gcontext.ClearHandler(m)}
	idleConnClosed := make(chan struct{})
	go func() {
		stop := make(chan os.Signal, 1)
		signal.Notify(stop, os.Interrupt)
		<-stop

		mm.Stop()
		// Shutdown close http connection gracefully
		if err := hs.Shutdown(context.Background()); err != nil {
			logger.Printf("HTTP server Shutdown(%v)", err)
		}
		close(idleConnClosed)
	}()

	// serve http
	if err := hs.ListenAndServe(); err != http.ErrServerClosed {
		logger.Printf("HTTP server ListenAndServe Err(%v)", err)
	}
	<-idleConnClosed
}
