package main

import "os"
import "os/signal"
import "log"
import "git.humbler.games/spaceknights/spaceknights/pkg/game"

func main() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt)

	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)
	server := game.NewServer(":9999", ":9989", logger)
	server.Run()
	select {
	case <-c:
		server.Stop()
	}
}
