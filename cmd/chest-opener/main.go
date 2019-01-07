package main

import "fmt"
import "flag"
import "time"
import "math/rand"
import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/lobby"

func main() {
	var name string
	var arena int
	flag.StringVar(&name, "name", "Silver", "name of the chest")
	flag.IntVar(&arena, "arena", 0, "index of the arena, 0 means Thanatos")
	flag.Parse()
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	fmt.Println(lobby.OpenChest(r, name, data.Arena(arena)))
}
