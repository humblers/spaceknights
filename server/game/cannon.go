package main

func NewCannon(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "building",
        Name: "cannon",
        Layer: Ground,
        TargetLayers : []Layer{Ground},
        Hp: 300,
        Speed: 0,
        PreHitDelay: 8,
        PostHitDelay: 0,
        Radius: 30,
        Sight: 100,
        Range: 100,
        Damage: 15,
        LifetimeCost: 1,
        Position: Vector2 { x, 200 },
    }
}
