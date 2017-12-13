package main

func NewKnightBullet(t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Bullet,
        Name:          "knightbullet",
        Layer:         Air,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Troop, Building, Knight},
        Speed:         20,
        Radius:        12,
        Damage:        50,
        Position:      pos,
    }
}
