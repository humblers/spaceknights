package main

func NewDrillram(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "drillram",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Building, Knight},
		Hp:           1408,
		InvMass:      18.0 / 100,
		Speed:        6,
		PreHitDelay:  4,
		PostHitDelay: 10,
		Radius:       14,
		Size:         Medium,
		Sight:        120,
		Range:        15,
		Damage:       264,
		Id:           id,
		Position:     pos,
	}
}
