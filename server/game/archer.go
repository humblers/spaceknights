package main

func NewArcher(t Team, x float64) *Unit {
    return &Unit{
        Team: t,
        Type: Troop,
        Name: "archer",
        Layer: Ground,
        TargetLayers : Layers{Ground, Air},
        TargetTypes: Types{Troop, Building},
        Hp: 60,
        Mass: 6,
        Speed: 3,
        PreHitDelay: 0,
        PostHitDelay: 9,
        Radius: 10,
        Sight: 100,
        Range: 100,
        Damage: 5,
        Position: Vector2 { x, 200 },
    }
}
