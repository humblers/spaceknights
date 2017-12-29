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
    var position Vector2
    switch t {
    case Home:
        position = Vector2{ MapWidth / 2, MapHeight - TileHeight * 2 }
    case Visitor:
        position = Vector2{ MapWidth / 2, TileHeight * 2 }
    }
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
        PostHitDelay:   20,
        Radius:         radius,
        Range:          80,
        Damage:         200,
        SpawnThing:     "knightbullet",
        SpawnSpeed:     15,
        RepairDelay:    15,
        SpawnFrame:     15,
        Position:       position,
        Destination:    position,
    }
}
