package main

func NewKnightBullet(t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Bullet,
        Name:          "knightbullet",
        Layer:         Air,
        TargetLayers : Layers{Ground, Air},
        TargetTypes:   Types{Knight, Troop, Building},
        Speed:         8,
        Radius:        5,
        Damage:        40,
        Position:      pos,
    }
}
