package main

import "log"

func NewKnight(t Team, name string, pos_x float64) *Unit {
    var prehitdelay int
    var posthitdelay int
    var radius float64
    var damage int
    switch name {
    case "shuriken":
        prehitdelay = 3
        posthitdelay = 0
        radius = 10
        damage = 30
    case "space_z":
        prehitdelay = 10
        posthitdelay = 19
        radius = 10
        damage = 100
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
        Hp:             2000,
        Speed:          1.2,
        PreHitDelay:    prehitdelay,
        PostHitDelay:   posthitdelay,
        Radius:         radius,
        Range:          80,
        Damage:         damage,
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
