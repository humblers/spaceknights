package main

func NewBomber(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "troop",
        Name: "bomber",
        Layer: Ground,
        TargetLayers : []Layer{Ground},
        Hp: 50,
        Speed: 5,
        PreHitDelay: 5,
        PostHitDelay: 0,
        Radius: 10,
        Sight: 100,
        Range: 100,
        Damage: 5,
        DamageRadius: 15,
        Position: Vector2 { x, 200 },
    }
}