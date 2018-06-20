package main

func NewGargoyleking(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "gargoyleking",
		Layer:        Air,
		TargetLayers: Layers{Ground, Air},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           695,
		InvMass:      1.0 / 20,
		Speed:        3,
		PreHitDelay:  3,
		PostHitDelay: 11,
		Radius:       20,
		Size:         Large,
		Sight:        100,
		Range:        20,
		Damage:       258,
		Id:           id,
		Position:     pos,
	}
}
