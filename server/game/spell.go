package main

import (
    "fmt"
    "math"
)

type Spell struct {
    // invariant
    Team        Team
    Name        string
    Damage      int     `json:"-"`
    Radius      float64 `json:"-"`
    Duration    int     `json:"-"`

    // variant
    Id          int     `json:"-"`
    Game        *Game   `json:"-"`
    Knight      *Unit
}

func (s *Spell) String() string {
    return fmt.Sprintf("%v(%v)", s.Name, s.Id)
}

func (s *Spell) AffectToUnits(filter func(*Unit) bool, behavior func(*Unit)) {
    for _, unit := range s.Game.Units {
        if filter(unit) {
            behavior(unit)
        }
    }
}

func (s *Spell) Update() {
    s.AffectToUnits(func (unit *Unit) bool {
        if s.Team == unit.Team {
            return false
        }
        if unit.IsCore() {
            return false
        }
        if math.Abs(s.Knight.Position.X - unit.Position.X) > s.Radius + unit.Radius {
            return false
        }
        return true
    }, func (unit *Unit) {
        unit.TakeDamage(s.Damage, nil)
    })
    if s.Knight.IsDead() {
        delete(s.Game.Spells, s.Id)
    }
    if s.Duration--; s.Duration < 0 {
        delete(s.Game.Spells, s.Id)
    }
}

func NewLaser(id int, team Team, knight *Unit) *Spell {
    return &Spell{
        Team:       team,
        Name:       "laser",
        Damage:     10,
        Radius:     15,
        Duration:   50,
        Id:         id,
        Knight:     knight,
    }
}