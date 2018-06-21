package main

func NewFelhound(id int, t Team, pos Vector2, offset Vector2) *Unit {
	if t == Home {
		offset = offset.FlipY()
	}
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "felhound",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           80,
		InvMass:      1.0 / 8,
		Speed:        3,
		PreHitDelay:  15,
		PostHitDelay: 14,
		Radius:       11,
		Size:         Small,
		Sight:        100,
		Range:        15,
		Damage:       80,
		Id:           id,
		Position:     pos.Plus(offset.Multiply(11)),
	}
}
