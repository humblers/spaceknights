package main

func NewArcher(id int, t Team, pos Vector2, offset Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "archer",
        Layer:         Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Troop, Building},
        Hp:            125,
        InvMass:       1.0/6,
        Speed:         3,
        PreHitDelay:   4,
        PostHitDelay:  7,
        Radius:        9,
        Size:          Small,
        Sight:         100,
        Range:         100,
        Damage:        40,
        Id:            id,
        Position:      pos.Plus(offset.Multiply(9)),
    }
}
