package main

func NewWasp(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "Wasp",
		Layer:        Air,
		TargetLayers: Layers{Ground, Air},
		TargetTypes:  Types{Building, Knight},
		Hp:           1000,
		InvMass:      1.0 / 20,
		Speed:        3,
		PreHitDelay:  7,
		PostHitDelay: 2,
		Radius:       20,
		Size:         Large,
		Sight:        100,
		Range:        20,
		Damage:       300,
		Id:           id,
		Position:     pos,
	}
}
