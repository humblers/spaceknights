package main

func NewGiant(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "giant",
        Layer: Ground,
        TargetLayers : Layers{Ground},
        TargetTypes : Types{Building},
        Hp: 320,
        Mass: 20,
        Speed: 2,
        PreHitDelay: 8,
        PostHitDelay: 5,
        Radius: 28,
        Sight: 200,
        Range: 15,
        Damage: 20,
        Position: Vector2 { x, 200 },
    }
}
