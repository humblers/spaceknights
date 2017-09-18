package main

func NewMegaminion(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "megaminion",
        Layer: Air,
        TargetLayers : Layers{Ground, Air},
        TargetTypes: Types{Troop, Building},
        Hp: 200,
        Mass: 20,
        Speed: 3,
        PreHitDelay: 4,
        PostHitDelay: 2,
        Radius: 20,
        Sight: 80,
        Range: 50,
        Damage: 10,
        Position: Vector2 { x, 200 },
    }
}
