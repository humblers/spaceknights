package main

func NewMegaminion(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "megaminion",
        Layer: Air,
        TargetLayers : Layers{Ground, Air},
        TargetTypes: Types{Troop, Building},
        Hp: 395,
        Mass: 20,
        Speed: 3,
        PreHitDelay: 3,
        PostHitDelay: 11,
        Radius: 20,
        Sight: 80,
        Range: 20,
        Damage: 147,
        Position: Vector2 { x, 200 },
    }
}
