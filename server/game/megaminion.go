package main

func NewMegaminion(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "troop",
        Name: "megaminion",
        Layer: Air,
        TargetLayers : []Layer{Ground, Air},
        Hp: 200,
        Speed: 3,
        PreHitDelay: 5,
        PostHitDelay: 0,
        Radius: 18,
        Sight: 80,
        Range: 50,
        Damage: 10,
        Position: Vector2 { x, 200 },
    }
}
