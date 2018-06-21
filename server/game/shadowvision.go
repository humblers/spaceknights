package main

func NewShadowvision(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "shadowvision",
		Layer:        Air,
		TargetLayers: Layers{Ground, Air},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           800,
		InvMass:      1.0 / 20,
		Speed:        3,
		PreHitDelay:  19,
		PostHitDelay: 0,
		Radius:       20,
		Size:         Large,
		Sight:        100,
		Range:        80,
		Damage:       258,
		Id:           id,
		Position:     pos,
	}
}
