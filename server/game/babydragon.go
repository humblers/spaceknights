package main

func NewBabydragon(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "babydragon",
        Name: "babydragon",
        Position: Vector2 { x, 200 },
        Layer: Air,
        TargetLayers : []Layer{Ground, Air},
        Hp: 200,
        Speed: 3,
        HitAfter: 5,
        HitCycle: 5,
        Radius: 18,
        Sight: 80,
        Range: 50,
        Damage: 10,
    }
}