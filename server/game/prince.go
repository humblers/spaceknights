package main

func NewPrince(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "prince",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Troop, Building},
        Hp:            1100,
        InvMass:       1.0/8,
        Speed:         3,
        PreHitDelay:   3,
        PostHitDelay:  11,
        Radius:        14,
        Sight:         200,
        Range:         15,
        Damage:        200,
        Id:            id,
        Position:      pos,
    }
}
