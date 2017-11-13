package main

func NewPekka(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "pekka",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Troop, Building},
        Hp:            2610,
        InvMass:       1.0/25,
        Speed:         1,
        PreHitDelay:   5,
        PostHitDelay:  12,
        Radius:        13,
        Size:          Medium,
        Sight:         100,
        Range:         15,
        Damage:        450,
        Id:            id,
        Position:      pos,
    }
}
