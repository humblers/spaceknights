package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
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

	f, err := firebase.NewApp(context.Background(), nil, option.WithCredentialsFile("humbler-8830f-firebase-adminsdk-czm59-aa395e102e.json"))
	if err != nil {
		panic(err)
	}

	// set http mux for routing
	m := http.NewServeMux()
	m.Handle(lobby.NewAuthRouter("/auth/", f, p, logger))
	m.Handle(lobby.NewDataRouter("/data/", p, logger))
	m.Handle(lobby.NewEditRouter("/edit/", p, logger))
	m.Handle(lobby.NewChestRouter("/chest/", p, logger))
	m.Handle(lobby.NewMatchRouter("/match/", p, logger))
	fileServer := http.FileServer(http.Dir("./statics"))
	hideDirListing := func(fileServer http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if strings.HasSuffix(r.URL.Path, "/") {
				http.NotFound(w, r)
				return
			}
			fileServer.ServeHTTP(w, r)
		})
	}
	m.Handle("/static/", http.StripPrefix("/static", hideDirListing(fileServer)))
	m.HandleFunc("/healthcheck", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	// gracefully shutdown http server
	hs := &http.Server{Addr: ":8080", Handler: m}
	idleConnClosed := make(chan struct{})
	go func() {
		stop := make(chan os.Signal, 1)
		signal.Notify(stop, os.Interrupt)
		<-stop

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
