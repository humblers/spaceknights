package main

func NewPanzerkunstler(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "panzerkunstler",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           2056,
		InvMass:      1.0 / 10,
		Speed:        4.5,
		PreHitDelay:  33,
		PostHitDelay: 6,
		Radius:       12,
		Size:         Medium,
		Sight:        150,
		Range:        15,
		Damage:       598,
		DamageRadius:  50,
		Id:           id,
		Position:     pos,
	}
}
