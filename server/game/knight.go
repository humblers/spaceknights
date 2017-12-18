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
    startpos := Vector2{MapWidth / 2, MothershipBaseHeight + MothershipMainHeight + TileHeight * 1.5}
    return &Unit{
        Team:           t,
        Type:           Knight,
        Name:           name,
        Layer:          Ground,
        TargetLayers:   Layers{Air, Ground},
        TargetTypes:    Types{Troop},
        Hp:             1000,
        Speed:          6,
        PreHitDelay:    10,
        PostHitDelay:   19,
        Radius:         radius,
        Range:          80,
        Damage:         100,
        SpawnThing:     "knightbullet",
        SpawnSpeed:     2,
        RepairDelay:    30,
        Position:       startpos,
        Destination:    startpos,
    }
}
