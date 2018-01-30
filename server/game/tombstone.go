package main

func NewTombstone(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Building,
		Name:         "tombstone",
		Layer:        Ground,
		Hp:           422,
		InvMass:      0,
		Radius:       20,
		LifetimeCost: 1,
		SpawnThing:   "skeleton",
		SpawnSpeed:   29,
		Id:           id,
		Position:     pos,
	}
}
