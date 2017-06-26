package main

import (
    "time"
)

const PlayTime = time.Minute * 5
const FrameInterval = time.Millisecond * 100

type Game struct {
    Frame int
    Players map[string]*Player
    inputs chan Input
}

func NewGame(ids ...string) *Game {
    game := &Game{
        Frame: 0,
        Players: make(map[string]*Player),
        inputs: make(chan Input),
    }

    for _, id := range ids {
        game.Players[id] = NewPlayer(id)
        games[id] = game
    }

    go game.run()

    return game
}

func (game *Game) run() {
    tick := time.Tick(FrameInterval)
    timeout := time.After(PlayTime)

    for {
        select {
        case <-timeout:
            return
        case <-tick:
            game.update()
        case input := <-game.inputs:
            game.apply(input)
        }
    }
}

func (game *Game) update() {
    game.Frame++
}

func (game *Game) apply(input Input) {
    game.Players[input.id].Position += input.Move
}
