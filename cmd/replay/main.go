package main

import "os"
import "log"
import "flag"
import "bufio"
import "encoding/json"

import "git.humbler.games/spaceknights/spaceknights/pkg/game"

func main() {
	path := flag.String("path", "", "path to the replay file")
	flag.Parse()
	if *path == "" {
		flag.PrintDefaults()
		return
	}
	file, err := os.Open(*path)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	if !scanner.Scan() {
		panic("no game config found")
	}
	var cfg game.Config
	if err := json.Unmarshal(scanner.Bytes(), &cfg); err != nil {
		panic(err)
	}
	var states []game.State
	for scanner.Scan() {
		var state game.State
		if err := json.Unmarshal(scanner.Bytes(), &state); err != nil {
			panic(err)
		}
		states = append(states, state)
	}
	if err := scanner.Err(); err != nil {
		panic(err)
	}

	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)
	replay := game.NewReplay(cfg, states, logger)
	replay.Run(len(states))
}
