package main

func NewTrainee(id int, t Team, pos Vector2, offset Vector2) *Unit {
	if t == Home {
		offset = offset.FlipY()
	}
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "trainee",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           636,
		InvMass:      1.0 / 8,
		Speed:        3,
		PreHitDelay:  3,
		PostHitDelay: 11,
		Radius:       11,
		Size:         Small,
		Sight:        100,
		Range:        15,
		Damage:       159,
		Id:           id,
		Position:     pos.Plus(offset.Multiply(11)),
	}
}
