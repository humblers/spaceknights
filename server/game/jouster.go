package main

func NewJouster(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:              t,
		Type:              Troop,
		Name:              "jouster",
		Layer:             Ground,
		TargetLayers:      Layers{Ground},
		TargetTypes:       Types{Troop, Building, Knight},
		Hp:                1243,
		InvMass:           1.0 / 8,
		Speed:             4.5,
		PreHitDelay:       3,
		PostHitDelay:      11,
		Radius:            13,
		Sight:             100,
		Range:             15,
		Damage:            206,
		DamageRadius:      30,
		TransformDuration: 10,
		Id:                id,
		Position:          pos,
	}
}