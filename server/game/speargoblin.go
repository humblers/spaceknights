package main

func NewSpeargoblin(t Team, pos Vector2, offset Vector2) *Unit {
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
        Position: pos.Plus(offset.Multiply(9)),
    }
}
