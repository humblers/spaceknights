package main

func NewBarbarian(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "barbarian",
        Layer: Ground,
        TargetLayers : Layers{Ground},
        TargetTypes: Types{Troop, Building},
        Hp: 80,
        Mass: 8,
        Speed: 5,
        PreHitDelay: 3,
        PostHitDelay: 6,
        Radius: 13,
        Sight: 100,
        Range: 15,
        Damage: 10,
        Position: Vector2 { x, 200 },
    }
}
