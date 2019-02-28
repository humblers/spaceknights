package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	firebase "firebase.google.com/go"
	"github.com/gomodule/redigo/redis"
	"google.golang.org/api/option"

	"github.com/humblers/spaceknights/pkg/lobby"
)

func main() {
	// global logger
	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)

	// set redis connection pool
	p := &redis.Pool{
		Dial:        func() (redis.Conn, error) { return redis.Dial("tcp", ":6379") },
		MaxIdle:     3,
		IdleTimeout: 240 * time.Second,
	}
	defer p.Close()

	f, err := firebase.NewApp(context.Background(), nil, option.WithCredentialsFile("test-8372b-firebase-adminsdk-4cule-5b08ab311e.json"))
	if err != nil {
		panic(err)
	}

	// set http mux for routing
	m := http.NewServeMux()
	m.Handle(lobby.NewAuthRouter("/auth/", f, p, logger))
	m.Handle(lobby.NewDataRouter("/data/", p, logger))
	m.Handle(lobby.NewEditRouter("/edit/", p, logger))
	m.Handle(lobby.NewChestRouter("/chest/", p, logger))
	path, mm := lobby.NewMatchMaker("/match/", p, logger)
	m.Handle(path, mm)

	// gracefully shutdown http server
	hs := &http.Server{Addr: ":8080", Handler: m}
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
