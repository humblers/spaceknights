package main

func NewBarbarian(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: "barbarian",
        Name: "barbarian",
        Position: Vector2 { x, 200 },
        Layer: Ground,
        AttackableLayers : []Layer{Ground},
        Hp: 80,
        Speed: 5,
        HitSpeed: 10,
        Radius: 12,
        Sight: 100,
        Range: 15,
        Damage: 10,
    }
}
