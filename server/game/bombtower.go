package main

func NewBombtower(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Building,
        Name:          "bombtower",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes :  Types{Troop, Building},
        Hp:            900,
        InvMass:       0,
        Speed:         0,
        PreHitDelay:   10,
        PostHitDelay:  5,
        Radius:        20,
        Size:          Large,
        Sight:         120,
        Range:         100,
        Damage:        100,
        DamageRadius:  30,
        LifetimeCost:  1,
        Id:            id,
        Position:      pos,
    }
}
