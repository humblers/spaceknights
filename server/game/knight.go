package main

import "log"

func NewKnight(t Team, name string, pos_x float64) *Unit {
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
        position = Vector2{ pos_x, MapHeight - TileHeight * 2 }
    case Visitor:
        position = Vector2{ pos_x, TileHeight * 2 }
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

func NewKnights(t Team, names []string) []*Unit {
    var knights []*Unit
    for idx, name := range names {
        var pos_x float64
        switch idx {
        case 0:
            pos_x = 70.0
        case 1:
            pos_x = MapWidth / 2
        case 2:
            pos_x = 330.0
        default:
            log.Panicf("too many knights(%v)", len(names))
        }
        knights = append(knights, NewKnight(t, name, pos_x))
    }
    return knights
}
