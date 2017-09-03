package main

func NewGiant(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "troop",
        Name: "giant",
        Layer: Ground,
        TargetLayers : []Layer{Ground},
        TargetExcludeTroopType: true,
        Hp: 320,
        Speed: 2,
        PreHitDelay: 8,
        PostHitDelay: 5,
        Radius: 38,
        Sight: 200,
        Range: 15,
        Damage: 20,
        Position: Vector2 { x, 200 },
    }
}