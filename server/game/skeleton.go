package main

func NewSkeleton(id int, t Team, pos Vector2, offset Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "skeleton",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Troop, Building},
        Hp:            30,
        Mass:          2,
        Speed:         4,
        PreHitDelay:   2,
        PostHitDelay:  7,
        Radius:        6,
        Sight:         100,
        Range:         5,
        Damage:        30,
        Id:            id,
        Position:      pos.Plus(offset.Multiply(6)),
    }
}
