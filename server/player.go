package main

type Player struct {
    Position int
    Hp int
}

func NewPlayer(id string) *Player {
    return &Player{
        Position: 0,
        Hp: 100,
    }
}

