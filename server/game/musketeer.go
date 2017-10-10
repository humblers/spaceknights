package main

func NewMusketeer(t Team, pos Vector2) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "musketeer",
        Layer: Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes: Types{Troop, Building},
        Hp: 340,
        Mass: 12,
        Speed: 3,
        PreHitDelay: 3,
        PostHitDelay: 7,
        Radius: 11,
        Sight: 120,
        Range: 120,
        Damage: 100,
        Position: pos,
    }
}
