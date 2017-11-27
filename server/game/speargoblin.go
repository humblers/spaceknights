package main

func NewSpeargoblin(id int, t Team, pos Vector2, offset Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "speargoblin",
        Layer:         Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Troop, Building},
        Hp:            50,
        InvMass:       1.0/7,
        Speed:         5,
        PreHitDelay:   4,
        PostHitDelay:  8,
        Radius:        9,
        Size:          Small,
        Sight:         200,
        Range:         80,
        Damage:        24,
        Id:            id,
        Position:      pos.Plus(offset.Multiply(9)),
    }
}
