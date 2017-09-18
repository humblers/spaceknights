package main

func NewCannon(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Building,
        Name: "cannon",
        Layer: Ground,
        TargetLayers : Layers{Ground},
        TargetTypes : Types{Troop, Building},
        Hp: 300,
        Mass: 100,
        Speed: 0,
        PreHitDelay: 5,
        PostHitDelay: 2,
        Radius: 20,
        Sight: 100,
        Range: 100,
        Damage: 15,
        LifetimeCost: 1,
        Position: Vector2 { x, 200 },
    }
}
