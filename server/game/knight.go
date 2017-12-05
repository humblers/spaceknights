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
        TargetTypes:    Types{Troop, Building},
        Hp:             1000,
        Speed:          6,
        PreHitDelay:    10,
        PostHitDelay:   4,
        Radius:         radius,
        Range:          180,
        Damage:         200,
        SpawnThing:     "knightbullet",
        SpawnSpeed:     2,
        RepairDelay:    15,
        SpawnUntil:     -1,
        Position:       startpos,
        Destination:    startpos,
    }
}
