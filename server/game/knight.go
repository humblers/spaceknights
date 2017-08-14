package main

import "log"

func NewKnight(t Team, name string) *Unit {
    p := Vector2{}
    p.X = MapWidth / 2; p.Y = TileHeight * 1.5
    var radius float64
    switch name {
    case "shuriken":
        radius = 20
    case "space_z":
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
