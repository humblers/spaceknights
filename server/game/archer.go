package main

func NewArcher(id int, t Team, pos Vector2, offset Vector2) *Unit {
	if t == Home {
		offset = offset.FlipY()
	}
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "archer",
		Layer:        Ground,
		TargetLayers: Layers{Ground, Air},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           254,
		InvMass:      1.0 / 6,
		Speed:        3,
		PreHitDelay:  1,
		PostHitDelay: 4,
		Radius:       9,
		Size:         Small,
		Sight:        100,
		Range:        70,
		Damage:       43,
		Id:           id,
		Position:     pos.Plus(offset.Multiply(9)),
	}
}
