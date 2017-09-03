package main

func NewArcher(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "troop",
        Name: "archer",
        Layer: Ground,
        TargetLayers : []Layer{Ground, Air},
        Hp: 60,
        Speed: 3,
        PreHitDelay: 5,
        PostHitDelay: 0,
        Radius: 10,
        Sight: 100,
        Range: 100,
        Damage: 5,
        Position: Vector2 { x, 200 },
    }
}
