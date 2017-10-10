package main

func NewBarbarian(t Team, pos Vector2, offset Vector2) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "barbarian",
        Layer: Ground,
        TargetLayers : Layers{Ground},
        TargetTypes: Types{Troop, Building},
        Hp: 300,
        Mass: 8,
        Speed: 3,
        PreHitDelay: 3,
        PostHitDelay: 11,
        Radius: 11,
        Sight: 100,
        Range: 15,
        Damage: 75,
        Position: pos.Plus(offset.Multiply(11)),
    }
}
