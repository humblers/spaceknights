package main

func NewBombtower(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Building,
		Name:         "bombtower",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           1672,
		InvMass:      0,
		Speed:        0,
		PreHitDelay:  10,
		PostHitDelay: 5,
		Radius:       20,
		Size:         Large,
		Sight:        120,
		Range:        120,
		Damage:       176,
		DamageRadius: 30,
		LifetimeCost: 4,
		Id:           id,
		Position:     pos,
	}
}
