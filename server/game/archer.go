package main

func NewArcher(t Team, pos Vector2, offset Vector2) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "archer",
        Layer: Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes: Types{Troop, Building},
        Hp: 125,
        Mass: 6,
        Speed: 3,
        PreHitDelay: 11,
        PostHitDelay: 0,
        Radius: 9,
        Sight: 100,
        Range: 100,
        Damage: 40,
        Position: pos.Plus(offset.Multiply(9)),
    }
}
