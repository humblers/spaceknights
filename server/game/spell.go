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
    Player      *Player `json:"-"`
    Position    Vector2
}

func (s *Spell) String() string {
    return fmt.Sprintf("%v(%v)", s.Name, s.Id)
}

func (s *Spell) ApplyWithinRangeUnits(filter func(*Unit) bool, behavior func(*Unit)) {
    for _, unit := range s.Game.Units {
        if filter(unit) {
            behavior(unit)
        }
    }
}

func (s *Spell) Update() {
    s.Position.X = s.Player.Knight.Position.X
    s.ApplyWithinRangeUnits(func (unit *Unit) bool {
        if math.Abs(s.Position.X - unit.Position.X) > s.Radius + unit.Radius {
            return false
        }
        return true
    }, func (unit *Unit) {
        unit.TakeDamage(s.Damage, nil)
    })
    if s.Duration--; s.Duration < 0 {
        delete(s.Game.Spells, s.Id)
    }
}

func NewLaser(id int, player *Player) *Spell {
    return &Spell{
        Team:       player.Team,
        Name:       "beam",
        Damage:     30,
        Radius:     15,
        Duration:   10,
        Player:     player,
        Position:   Vector2{player.Knight.Position.X, MapHeight / 2},
    }
}