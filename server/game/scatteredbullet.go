package main

func NewScatteredBullet(t Team, pos Vector2) *Unit {
    return &Unit{
        Team:          t,
        Type:          Bullet,
        Name:          "scatteredbullet",
        Layer:         Air,
        TargetLayers : Layers{Air},
        TargetTypes:   Types{Knight},
        Speed:         3,
        Radius:        7,
        Damage:        40,
        Position:      pos,
    }
}
