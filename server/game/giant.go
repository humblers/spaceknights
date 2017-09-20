package main

func NewGiant(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "giant",
        Layer: Ground,
        TargetLayers : Layers{Ground},
        TargetTypes : Types{Building},
        Hp: 2000,
        Mass: 32,
        Speed: 1,
        PreHitDelay: 8,
        PostHitDelay: 6,
        Radius: 28,
        Sight: 200,
        Range: 15,
        Damage: 126,
        Position: Vector2 { x, 200 },
    }
}
