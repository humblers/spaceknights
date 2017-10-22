package main

func NewGoblinhut(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:         t,
        Type:         Building,
        Name:         "goblinhut",
        Layer:        Ground,
        Hp:           600,
        Mass:         100,
        Radius:       20,
        LifetimeCost: 1,
        SpawnThing:   "speargoblin",
        SpawnSpeed:   49,
        Id:           id,
        Position:     pos,
    }
}
