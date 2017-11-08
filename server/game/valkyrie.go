package main

func NewValkyrie(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "valkyrie",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Troop, Building},
        Hp:            880,
        Mass:          15,
        Speed:         3,
        PreHitDelay:   8,
        PostHitDelay:  6,
        Radius:        12,
        Size:          Medium,
        Sight:         100,
        Range:         20,
        Damage:        120,
        Id:            id,
        Position:      pos,
    }
}
