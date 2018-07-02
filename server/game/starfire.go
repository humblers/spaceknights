package main

func NewStarfire(id int, t Team, pos Vector2, offset Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "starfire",
		Layer:        Ground,
		TargetLayers: Layers{Ground, Air},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           598,
		InvMass:      1.0 / 12,
		Speed:        3,
		PreHitDelay:  3,
		PostHitDelay: 7,
		Radius:       11,
		Size:         Large,
		Sight:        100,
		Range:        85,
		Damage:       176,
		Id:           id,
		Position:     pos.Plus(offset.Multiply(11)),
	}
}
