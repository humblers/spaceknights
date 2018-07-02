package main

func NewBerserker(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "berserker",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           1056,
		InvMass:      1.0 / 10,
		Speed:        4.5,
		PreHitDelay:  5,
		PostHitDelay: 12,
		Radius:       12,
		Size:         Small,
		Sight:        150,
		Range:        15,
		Damage:       598,
		Id:           id,
		Position:     pos,
	}
}
