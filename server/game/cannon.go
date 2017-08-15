package main

func NewCannon(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "cannon",
        Name: "cannon",
        Position: Vector2 { x, 200 },
        Layer: Ground,
        Hp: 100,
        Speed: 0,
        HitSpeed: 8,
        Radius: 30,
        Sight: 100,
        Range: 100,
        Damage: 15,
    }
}
