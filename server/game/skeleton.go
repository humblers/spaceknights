package main

func NewSkeleton(id int, t Team, pos Vector2, offset Vector2) *Unit {
	if t == Home {
		offset = offset.FlipY()
	}
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "skeleton",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building},
		Hp:           67,
		InvMass:      1.0 / 2,
		Speed:        4.5,
		PreHitDelay:  2,
		PostHitDelay: 7,
		Radius:       6,
		Size:         Small,
		Sight:        100,
		Range:        5,
		Damage:       67,
		Id:           id,
		Position:     pos.Plus(offset.Multiply(6)),
	}
}
