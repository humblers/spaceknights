package main

import (
	"fmt"
	"math"
)

const FreezeDuration = 60
const LaserRange = 150
const KnightCastSpeed = 30

type Spell struct {
	// invariant
	Team     Team
	Name     string
	Damage   int     `json:"-"`
	Range    int     `json:"-"`
	Radius   float64 `json:"-"`
	Duration int     `json:"-"`

	// variant
	Id       int   `json:"-"`
	Game     *Game `json:"-"`
	Position Vector2
	Knight   *Unit `json:"-"`
}

func (s *Spell) String() string {
	return fmt.Sprintf("%v(%v)", s.Name, s.Id)
}

func (s *Spell) AffectToUnits(filter func(*Unit) bool, behavior func(*Unit)) {
	for _, unit := range s.Game.Units {
		if s.Team == unit.Team {
			continue
		}
		if filter(unit) {
			behavior(unit)
		}
	}
}

func (s *Spell) Update() {
	if s.Duration < 0 {
		delete(s.Game.Spells, s.Id)
		if s.Name == "laser" {
			s.Knight.WaitingSpell.Finished = true
		}
		return
	}
	s.Duration--

	var filter func(unit *Unit) bool
	switch s.Name {
	case "laser":
		filter = func(unit *Unit) bool {
			if math.Abs(s.Position.X-unit.Position.X) > s.Radius+unit.Radius {
				return false
			}
			if math.Abs(s.Position.Y-unit.Position.Y) > float64(s.Range)+unit.Radius {
				return false
			}
			return true
		}
		s.AffectToUnits(filter, func(unit *Unit) {
			damage := s.Damage
			if unit.IsCore() {
				damage = damage * 10 / 100
			}
			unit.TakeDamage(s.Damage, nil)
		})
	case "fireball":
		filter = func(unit *Unit) bool {
			if s.Position.Minus(unit.Position).Length() > s.Radius+unit.Radius {
				return false
			}
			return true
		}
		s.AffectToUnits(filter, func(unit *Unit) {
			damage := s.Damage
			if unit.IsCore() {
				damage = damage * 30 / 100
			}
			unit.TakeDamage(s.Damage, nil)
		})
	case "freeze":
		if s.Duration == FreezeDuration-1 {
			filter = func(unit *Unit) bool {
				if unit.Type == Troop || unit.Type == Building {
					if s.Position.Minus(unit.Position).Length() < s.Radius+unit.Radius {
						return true
					}
				}
				return false
			}
			s.AffectToUnits(filter, func(unit *Unit) {
				unit.Freeze(FreezeDuration)
			})
		}
	}
}

func NewLaser(id int, team Team, pos Vector2, knight *Unit) *Spell {
	return &Spell{
		Team:     team,
		Name:     "laser",
		Damage:   12,
		Range:    LaserRange,
		Radius:   20,
		Duration: 50,
		Id:       id,
		Position: pos,
		Knight:   knight,
	}
}

func NewFireball(id int, team Team, pos Vector2) *Spell {
	return &Spell{
		Team:     team,
		Name:     "fireball",
		Damage:   572,
		Radius:   50,
		Id:       id,
		Position: pos,
	}
}

func NewFreeze(id int, team Team, pos Vector2) *Spell {
	return &Spell{
		Team:     team,
		Name:     "freeze",
		Radius:   60,
		Duration: FreezeDuration,
		Id:       id,
		Position: pos,
	}
}
