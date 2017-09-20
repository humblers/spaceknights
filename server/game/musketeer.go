package main

func NewMusketeer(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "muketeer",
        Layer: Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes: Types{Troop, Building},
        Hp: 340,
        Mass: 12,
        Speed: 3,
        PreHitDelay: 10,
        PostHitDelay: 0,
        Radius: 11,
        Sight: 120,
        Range: 120,
        Damage: 100,
        Position: Vector2 { x, 200 },
    }
}
