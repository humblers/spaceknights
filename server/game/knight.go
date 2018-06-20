package main

import "log"

const KnightBulletRange = 200
const KnightOffsetY = TileHeight * 1

func NewKnight(t Team, name string, pos_x float64, index int) *Unit {
	unit := &Unit{
		Team:         t,
		Type:         Knight,
		Name:         name,
		Layer:        Ground,
		TargetLayers: Layers{Air, Ground},
		TargetTypes:  Types{Troop, Building},
		Speed:        5,
		KnightIndex:  index,
	}
	switch name {
	case "legion", "frost", "judge":
		unit.Hp = 2534 * 2 / 3
		unit.PreHitDelay = 3
		unit.PostHitDelay = 0
		unit.Radius = 10
		unit.Damage = 30 / 2
		unit.Range = 112
	case "astra", "lancer", "nagmash":
		unit.Hp = 4008 * 2 / 3
		unit.PreHitDelay = 10
		unit.PostHitDelay = 19
		unit.Radius = 10
		unit.Damage = 100 / 2
		unit.Range = KnightBulletRange
		unit.SpawnThing = "knightbullet"
		unit.SpawnSpeed = 2
	default:
		log.Panicf("unknown knight name: %v", name)
	}
	var position Vector2
	switch t {
	case Home:
		position = Vector2{pos_x, MapHeight - KnightOffsetY}

	case Visitor:
		position = Vector2{MapWidth - pos_x, KnightOffsetY}
	}
	unit.Position = position
	unit.Destination = position
	unit.InitialPosition = position
	return unit
}

func NewKnights(t Team, names []string) []*Unit {
	var knights []*Unit
	for idx, name := range names {
		var pos_x float64
		switch idx {
		case 0:
			pos_x = 56
		case 1:
			pos_x = MapWidth / 2
		case 2:
			pos_x = 264
		default:
			log.Panicf("too many knights(%v)", len(names))
		}
		knights = append(knights, NewKnight(t, name, pos_x, idx))
	}
	return knights
}
