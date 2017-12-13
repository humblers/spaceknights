package main

func NewBomber(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "bomber",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Building, Troop, Knight},
        Hp:            150,
        InvMass:       1.0/5,
        Speed:         3,
        PreHitDelay:   10,
        PostHitDelay:  9,
        Radius:        11,
        Size:          Medium,
        Sight:         100,
        Range:         70,
        Damage:        100,
        DamageRadius:  25,
        Id:            id,
        Position:      pos,
    }
}
