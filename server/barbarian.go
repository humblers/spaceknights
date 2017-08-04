package main

func NewBarbarian(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Name: "barbarian",
        Position: Vector2 { x, 200 },
        Layer: Ground,
        Hp: 80,
        Radius: 12,
        Sight: 100,
        Range: 15,
        Damage: 10,
    }
}
