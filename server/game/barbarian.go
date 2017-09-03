package main

func NewBarbarian(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "barbarian",
        Name: "barbarian",
        Layer: Ground,
        TargetLayers : []Layer{Ground},
        Hp: 80,
        Speed: 5,
        PreHitDelay: 3,
        PostHitDelay: 6,
        Radius: 12,
        Sight: 100,
        Range: 15,
        Damage: 10,
        Position: Vector2 { x, 200 },
    }
}
