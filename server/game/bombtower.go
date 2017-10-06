package main

func NewBombtower(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Building,
        Name: "bombtower",
        Layer: Ground,
        TargetLayers : Layers{Ground},
        TargetTypes : Types{Troop, Building},
        Hp: 900,
        Mass: 120,
        Speed: 0,
        PreHitDelay: 15,
        PostHitDelay: 0,
        Radius: 20,
        Sight: 120,
        Range: 120,
        Damage: 100,
        LifetimeCost: 1,
        Position: Vector2 { x, 200 },
    }
}
