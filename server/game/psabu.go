package main

func NewPsabu(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "psabu",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           3458,
		InvMass:      1.0 / 25,
		Speed:        2.25,
		PreHitDelay:  31,
		PostHitDelay: 18,
		Radius:       13,
		Size:         Medium,
		Sight:        150,
		Range:        15,
		Damage:       678,
		DamageRadius: 60,
		Id:           id,
		Position:     pos,
	}
}
