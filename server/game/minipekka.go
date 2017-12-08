package main

func NewMinipekka(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "minipekka",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Troop, Building},
        Hp:            600,
        InvMass:       1.0/10,
        Speed:         4,
        PreHitDelay:   5,
        PostHitDelay:  12,
        Radius:        12,
        Size:          Small,
        Sight:         300,
        Range:         15,
        Damage:        325,
        Id:            id,
        Position:      pos,
    }
}
