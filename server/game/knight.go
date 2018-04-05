package main

import "log"

const KnightBulletRange = 200
const KnightOffsetY = TileHeight * 1

func NewKnight(t Team, name string, pos_x float64, index int) *Unit {
	var hp int
	var prehitdelay, posthitdelay int
	var radius float64
	var damage int
	switch name {
	case "shuriken":
		hp = 2534
		prehitdelay = 3
		posthitdelay = 0
		radius = 10
		damage = 30
	case "space_z":
		hp = 4008
		prehitdelay = 10
		posthitdelay = 19
		radius = 10
		damage = 100
	case "freezer":
		hp = 2534
		prehitdelay = 3
		posthitdelay = 0
		radius = 10
		damage = 30
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
	return &Unit{
		Team:            t,
		Type:            Knight,
		Name:            name,
		Layer:           Ground,
		TargetLayers:    Layers{Air, Ground},
		TargetTypes:     Types{Troop, Building},
		Hp:              hp * 2 / 3,
		Speed:           5,
		PreHitDelay:     prehitdelay,
		PostHitDelay:    posthitdelay,
		Radius:          radius,
		Range:           KnightBulletRange,
		Damage:          damage / 2,
		SpawnThing:      "knightbullet",
		SpawnSpeed:      2,
		RepairDelay:     15,
		Position:        position,
		Destination:     position,
		KnightIndex:     index,
		InitialPosition: position,
	}
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
