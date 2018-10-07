package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
	gcontext "github.com/gorilla/context"
	"github.com/gorilla/securecookie"
	"github.com/humblers/spaceknights/pkg/lobby"
)

func main() {
	// global logger
	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)

	// set redis connection pool
	p := &redis.Pool{
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", ":6379")
			if err != nil {
				return nil, err
			}
			return c, nil
		},

		MaxIdle:     3,
		IdleTimeout: 240 * time.Second,
	}

	// redis session store with session key(key get or generate)
	rc := p.Get()
	defer rc.Close()
	key := "session:key"
	if _, err := rc.Do("WATCH", key); err != nil {
		panic(err)
	}
	sk, err := redis.Bytes(rc.Do("GET", key))
	switch err {
	case nil:
		rc.Do("UNWATCH", key)
	case redis.ErrNil:
		sk = securecookie.GenerateRandomKey(32)
		rc.Send("MULTI")
		rc.Send("SET", key, sk)
		if rep, err := rc.Do("EXEC"); rep == nil || err != nil {
			panic(fmt.Errorf("error occured while session key generating: %v", err))
		}
	default:
		panic(err)
	}
	ss, err := redistore.NewRediStoreWithPool(p, sk)
	if err != nil {
		panic(err)
	}
	defer ss.Close()
	ss.SetKeyPrefix("session:")

	// load various game data from redis
	lobby.LoadDataFromDB(p, false)

	// set http mux for routing
	m := http.NewServeMux()
	m.Handle(lobby.NewAuthRouter("/auth/", ss, p, logger))
	m.Handle(lobby.NewDataRouter("/data/", ss, p, logger))
	path, mm := lobby.NewMatchMaker("/match/", ss, p, logger)
	m.Handle(path, mm)

	// gracefully shutdown http server
	hs := &http.Server{Addr: ":8080", Handler: gcontext.ClearHandler(m)}
	idleConnClosed := make(chan struct{})
	go func() {
		stop := make(chan os.Signal, 1)
		signal.Notify(stop, syscall.SIGINT)
		<-stop

		mm.Stop()
		// Shutdown close http connection gracefully
		if err := hs.Shutdown(context.Background()); err != nil {
			logger.Printf("HTTP server Shutdown(%v)", err)
		}
		close(idleConnClosed)

		p.Close()
	}()

	// serve http
	if err := hs.ListenAndServe(); err != http.ErrServerClosed {
		logger.Printf("HTTP server ListenAndServe Err(%v)", err)
	}
	<-idleConnClosed
}
