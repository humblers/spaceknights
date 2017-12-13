package main

func NewMusketeer(id int, t Team, pos Vector2, offset Vector2)  *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "musketeer",
        Layer:         Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Troop, Building, Knight},
        Hp:            200,
        InvMass:       1.0/12,
        Speed:         3,
        PreHitDelay:   3,
        PostHitDelay:  7,
        Radius:        11,
        Size:          Large,
        Sight:         120,
        Range:         100,
        Damage:        100,
        Id:            id,
        Position:      pos.Plus(offset.Multiply(11)),
    }
}
