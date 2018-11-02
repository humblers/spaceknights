package main

import "os"
import "fmt"
import "log"
import "flag"
import "encoding/json"

import "github.com/gomodule/redigo/redis"
import "github.com/humblers/spaceknights/pkg/game"

func main() {
	var id string
	var step int
	flag.StringVar(&id, "id", "", "game id")
	flag.IntVar(&step, "step", 0, "run game until this step, 0 means run until game over")
	flag.Parse()
	if id == "" {
		flag.PrintDefaults()
		return
	}
	l := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)
	var rep game.Replay

	// get replay data
	if conn, err := redis.Dial("tcp", ":6379"); err != nil {
		l.Panic("cannot establish redis connection")
	} else {
		defer conn.Close()
		key := fmt.Sprintf("game:%v", id)
		if str, err := redis.String(conn.Do("GET", key)); err != nil {
			panic(err)
		} else {
			if err := json.Unmarshal([]byte(str), &rep); err != nil {
				panic(err)
			}
		}
	}

	// run game
	g := game.NewGame(rep.Config, rep.Actions, l)
	for !g.Over() {
		g.Update()
		if g.Step() == step {
			fmt.Println(g.World().Digest())
			g.PrintGameState()
			break
		}
	}
}
