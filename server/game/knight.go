package main

import "log"

func NewKnight(t Team, name string) *Unit {
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
        Team:           t,
        Type:           Knight,
        Name:           name,
        Layer:          Air,
        TargetLayers:   Layers{Air, Ground},
        TargetTypes:    Types{Troop, Building},
        Hp:             100,
        PreHitDelay:    10,
        PostHitDelay:   4,
        Radius:         radius,
        Range:          140,
        Damage:         100,
        SpawnThing:     "knightbullet",
        SpawnSpeed:     15,
        RepairDelay:    30,
        SpawnFrame:     15,
        Position:       Vector2{MapWidth / 2, TileHeight * 1.5},
    }
}
