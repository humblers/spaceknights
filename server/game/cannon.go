package main

func NewCannon(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Building,
        Name:          "cannon",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes :  Types{Troop, Building, Knight},
        Hp:            450,
        InvMass:       0,
        Speed:         0,
        PreHitDelay:   5,
        PostHitDelay:  2,
        Radius:        20,
        Size:          Large,
        Sight:         120,
        Range:         90,
        Damage:        60,
        LifetimeCost:  1,
        Id:            id,
        Position:      pos,
    }
}
