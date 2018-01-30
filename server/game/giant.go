package main

func NewGiant(id int, t Team, pos Vector2) *Unit {
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "giant",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Building},
		Hp:           3344,
		InvMass:      1.0 / 100,
		Speed:        2.25,
		PreHitDelay:  8,
		PostHitDelay: 6,
		Radius:       28,
		Size:         XLarge,
		Sight:        150,
		Range:        15,
		Damage:       211,
		Id:           id,
		Position:     pos,
	}
}
