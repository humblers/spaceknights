package main

import "log"

const (
    ShurikenHeight = 40
    SpaceZHeight = 62
)

type Knight struct {
    Team Team
    Name string
    Position Vector2
    Layer Layer
}

func NewKnight(team Team, name string) *Knight {
    k := Knight{
        Team: team,
        Name: name,
        Position: Vector2{
            X: MapWidth / 2,
        },
        Layer: Air,
    }
    switch name {
    case "shuriken":
        k.Position.Y = ShurikenHeight / 2
    case "space_z":
        k.Position.Y = SpaceZHeight / 2
    default:
        log.Panicf("unknown knight type: %v", name)
    }
    if team == Home {
        k.Position = k.Position.FlipY()
    }
    return &k
}

func (k *Knight) Update(game *Game) {
}
