package main

func NewGargoyle(id int, t Team, pos Vector2, offset Vector2) *Unit {
	if t == Home {
		offset = offset.FlipY()
	}
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "gargoyle",
		Layer:        Air,
		TargetLayers: Layers{Ground, Air},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           190,
		InvMass:      1.0 / 5,
		Speed:        4.5,
		PreHitDelay:  3,
		PostHitDelay: 6,
		Radius:       10,
		Sight:        100,
		Range:        20,
		Damage:       84,
		Id:           id,
		Position:     pos.Plus(offset.Multiply(10)),
	}
}
