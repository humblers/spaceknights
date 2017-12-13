package main

func NewDarkprince(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "darkprince",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Troop, Building, Knight},
        Hp:            920,
        InvMass:       1.0/8,
        Speed:         3,
        PreHitDelay:   3,
        PostHitDelay:  11,
        Radius:        13,
        Sight:         100,
        Range:         15,
        Damage:        75,
        DamageRadius:  15,
        Id:            id,
        Position:      pos,
    }
}
