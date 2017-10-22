package main

func NewBomber(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "bomber",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Building, Troop},
        Hp:            150,
        Mass:          5,
        Speed:         3,
        PreHitDelay:   19,
        PostHitDelay:  0,
        Radius:        11,
        Sight:         100,
        Range:         90,
        Damage:        100,
        DamageRadius:  15,
        Id:            id,
        Position:      pos,
    }
}
