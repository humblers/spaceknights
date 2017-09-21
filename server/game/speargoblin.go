package main

func NewSpeargoblin(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "speargoblin",
        Layer: Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes: Types{Troop, Building},
        Hp: 52,
        Mass: 7,
        Speed: 5,
        PreHitDelay: 12,
        PostHitDelay: 0,
        Radius: 9,
        Sight: 100,
        Range: 100,
        Damage: 24,
        Position: Vector2 { x, 200 },
    }
}
