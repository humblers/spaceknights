package main

func NewValkyrie(id int, t Team, pos Vector2) *Unit {
    rad, ran := 12.0, 20.0
    return &Unit{
        Team:          t,
        Type:          Troop,
        Name:          "valkyrie",
        Layer:         Ground,
        TargetLayers : Layers{Ground},
        TargetTypes:   Types{Troop, Building, Knight},
        Hp:            880,
        InvMass:       1.0/15,
        Speed:         3,
        PreHitDelay:   8,
        PostHitDelay:  6,
        Radius:        rad,
        Size:          Medium,
        Sight:         200,
        Range:         ran,
        Damage:        120,
        DamageRadius:  rad + ran,
        DamageCenter:  Self,
        Id:            id,
        Position:      pos,
    }
}
