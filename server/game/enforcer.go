package main

func NewEnforcer(id int, t Team, pos Vector2) *Unit {
	rad, ran := 12.0, 30.0
	return &Unit{
		Team:         t,
		Type:         Troop,
		Name:         "enforcer",
		Layer:        Ground,
		TargetLayers: Layers{Ground},
		TargetTypes:  Types{Troop, Building, Knight},
		Hp:           1548,
		InvMass:      1.0 / 15,
		Speed:        3,
		PreHitDelay:  8,
		PostHitDelay: 6,
		Radius:       rad,
		Size:         Medium,
		Sight:        100,
		Range:        ran,
		Damage:       221,
		DamageRadius: rad + ran,
		DamageCenter: Self,
		Id:           id,
		Position:     pos,
	}
}