package main

func NewSpeargoblin(id int, t Team, pos Vector2, offset Vector2) *Unit {
    if t == Home {
        offset = offset.FlipY()
    }
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "speargoblin",
        Layer:         Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Troop, Building},
        Hp:            110,
        InvMass:       1.0/7,
        Speed:         6,
        PreHitDelay:   4,
        PostHitDelay:  8,
        Radius:        9,
        Size:          Small,
        Sight:         100,
        Range:         100,
        Damage:        50,
        Id:            id,
        Position:      pos.Plus(offset.Multiply(9)),
    }
}
