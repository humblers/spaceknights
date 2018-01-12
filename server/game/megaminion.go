package main

func NewMegaminion(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "megaminion",
        Layer:         Air,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Troop, Building},
        Hp:            300,
        InvMass:       1.0/20,
        Speed:         3,
        PreHitDelay:   3,
        PostHitDelay:  11,
        Radius:        20,
        Size:          Large,
        Sight:         80,
        Range:         20,
        Damage:        147,
        Id:            id,
        Position:      pos,
    }
}
