package main

import "log"

func NewKnight(t Team, name string) *Unit {
    var radius float64
    switch name {
    case "shuriken":
        radius = 9
    case "space_z":
        radius = 12
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
        Range:          180,
        Damage:         150,
        SpawnThing:     "knightbullet",
        SpawnSpeed:     7,
        RepairDelay:    30,
        SpawnFrame:     15,
        Position:       Vector2{MapWidth / 2, TileHeight * 1.5},
    }
}
