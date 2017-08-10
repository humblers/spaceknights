package main

import "log"

const (
    ShurikenHeight = 40
    SpaceZHeight = 62
)

func NewKnight(t Team, name string) *Unit {
    p := Vector2{}
    var radius float64
    switch name {
    case "shuriken":
        p.X = MapWidth / 2; p.Y = ShurikenHeight / 2
        radius = 20
    case "space_z":
        p.X = MapWidth / 2; p.Y = SpaceZHeight / 2
        radius = 31
    default:
        log.Panicf("unknown knight name: %v", name)
    }
    return &Unit{
        Team: t,
        Type: "knight",
        Name: name,
        Position: p,
        Layer: Air,
        Hp: 100,
        Radius: radius,
    }
}
