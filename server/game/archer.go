package main

func NewArcher(t Team, x float64) *Unit {
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
        PreHitDelay: 0,
        PostHitDelay: 6,
        Radius: 9,
        Sight: 100,
        Range: 100,
        Damage: 40,
        Position: Vector2 { x, 200 },
    }
}
