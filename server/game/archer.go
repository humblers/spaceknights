package main

func NewArcher(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "archer",
        Name: "archer",
        Position: Vector2 { x, 200 },
        Layer: Ground,
        AttackableLayers : []Layer{Ground, Air},
        Hp: 60,
        Speed: 3,
        HitSpeed: 5,
        Radius: 10,
        Sight: 100,
        Range: 100,
        Damage: 5,
    }
}