package main

import (
    "fmt"
    "log"
    "time"
    "strings"
)

const PlayTime = 5 * time.Minute
const FrameInterval = time.Millisecond * 100

type Game struct {
    Frame int
    TeamA *Team
    TeamB *Team
}

func NewGame(A *Team, B *Team) *Game {
    game := Game{
        Frame: 0,
        TeamA: A,
        TeamB: B,
    }
    return &game
}

func (game *Game) GetPlayer(id string) *Player {
    if p := game.TeamA.Players[id]; p != nil {
        return p
    } else if p := game.TeamB.Players[id]; p != nil {
        return p
    } else {
        return p
    }
}

func (game *Game) String() string {
    var a, b []string
    for id, _ := range game.TeamA.Players {
        a = append(a, id)
    }
    for id, _ := range game.TeamB.Players {
        b = append(b, id)
    }
    return fmt.Sprintf("(%v VS %v)", strings.Join(a, ", "), strings.Join(b, ", "))
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
    player := game.GetPlayer(input.id)
    if input.Move != 0 {
        player.Knight.X += input.Move
    } else if input.Use != 0 {
        player.UseCard(input.Use - 1)
    }
}
