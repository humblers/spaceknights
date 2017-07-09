package main

import (
    "fmt"
    "log"
    "time"
    "strings"
)

const PlayTime = 5 * time.Minute
const FrameInterval = time.Millisecond * 100

type Player struct {
    Position int
    Hp int
}

type Game struct {
    Frame int
    Players map[string]*Player
}

func NewGame(ids ...string) *Game {
    game := Game{
        Frame: 0,
        Players: make(map[string]*Player),
    }
    for _, id := range ids {
        game.Players[id] = &Player{
            Position: 0,
            Hp: 100,
        }
    }
    return &game
}

func (game *Game) String() string {
    var ids []string
    for id, _ := range game.Players {
        ids = append(ids, id)
    }
    return fmt.Sprintf("(%v)", strings.Join(ids, ", "))
}

func (game *Game) Run(session *Session) {
    log.Printf("game %v starting", game)
    defer log.Printf("game %v stopped", game)
    tick := time.Tick(FrameInterval)
    over := time.After(PlayTime)
    for {
        select {
        case <-over:
            if err := session.Stop(); err != nil {
                panic(err)
            }
            return
        case <-tick:
            game.update()
            session.outgoing <- NewPacket(game)
        case input := <-session.incoming:
            game.apply(input)
        }
    }
}

func (game *Game) update() {
    game.Frame++
}

func (game *Game) apply(input Input) {
    game.Players[input.Id].Position += input.Move
}
