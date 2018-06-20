package main

func NewBarrack(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Building,
		Name:         "barrack",
		Layer:        Ground,
		Hp:           1936,
		InvMass:      0,
		Radius:       20,
		Size:         Large,
		LifetimeCost: 3,
		SpawnThing:   "footman",
		SpawnSpeed:   140,
		Id:           id,
		Position:     pos,
	}
}
