package main

func NewSentryshelter(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Building,
		Name:         "sentryshelter",
		Layer:        Ground,
		Hp:           1293,
		InvMass:      0,
		Radius:       20,
		Size:         Large,
		LifetimeCost: 2,
		SpawnThing:   "sentry",
		SpawnSpeed:   49,
		Id:           id,
		Position:     pos,
	}
}
