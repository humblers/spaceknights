package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"

	"github.com/humblers/spaceknights/pkg/game"
)

func main() {
	var host, port, lport string
	flag.StringVar(&host, "host", "127.0.0.1", "game server host")
	flag.StringVar(&port, "port", "9999", "game server port for client")
	flag.StringVar(&lport, "lport", "9989", "game server port for lobby")
	flag.Parse()

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt)

	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)
	server := game.NewServer(net.JoinHostPort(host, port), net.JoinHostPort("", lport), logger)
	server.Run()
	select {
	case sig := <-c:
		fmt.Fprintln(os.Stderr, "")
		logger.Printf("Got %v signal. Aborting...", sig)
		server.Stop()
	}
}
