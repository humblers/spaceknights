package main

func NewBarbarianhut(id int, t Team, pos Vector2) *Unit {
    return &Unit{
        Team:         t,
        Type:         Building,
        Name:         "barbarianhut",
        Layer:        Ground,
        Hp:           1200,
        Mass:         100,
        Radius:       20,
        Size:         Large,
        LifetimeCost: 2,
        SpawnThing:   "barbarians",
        SpawnSpeed:   140,
        Id:           id,
        Position:     pos,
    }
}
