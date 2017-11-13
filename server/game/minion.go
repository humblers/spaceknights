package main

func NewMinion(id int, t Team, pos Vector2, offset Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "minion",
        Layer:         Air,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Troop, Building},
        Hp:            90,
        InvMass:       1.0/5,
        Speed:         4,
        PreHitDelay:   3,
        PostHitDelay:  6,
        Radius:        10,
        Sight:         80,
        Range:         20,
        Damage:        40,
        Id:            id,
        Position:      pos.Plus(offset.Multiply(10)),
    }
}
