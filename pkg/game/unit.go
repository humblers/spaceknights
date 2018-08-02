package game

import "github.com/humblers/spaceknights/pkg/fixed"
import "github.com/humblers/spaceknights/pkg/physics"

type Layer string
type Layers []Layer

type Type string
type Types []Type

type Unit interface {
	Id() int
	Name() string
	Team() Team
	Type() Type
	Layer() Layer
	IsDead() bool
	TakeDamage(amount int)
	Update()
	Destroy()

	// from physics.Body
	Position() fixed.Vector
	SetPosition(p fixed.Vector)
	Radius() fixed.Scalar
	SetVelocity(v fixed.Vector)

	// for knight type
	Skill() string
	CastSkill(posX, posY int) bool
}

const (
	Ground    Layer = "Ground"
	Air       Layer = "Air"
	Invisible Layer = "Invisible"

	Troop    Type = "Troop"
	Building Type = "Building"
	Knight   Type = "Knight"
)

func (layers Layers) Contains(layer Layer) bool {
	for _, l := range layers {
		if l == layer {
			return true
		}
	}
	return false
}

func (types Types) Contains(type_ Type) bool {
	for _, t := range types {
		if t == type_ {
			return true
		}
	}
	return false
}

type unit struct {
	id    int
	name  string
	team  Team
	level int
	hp    int
	game  Game
	physics.Body
}

func newUnit(id int, name string, t Team, level, posX, posY int, g Game) *unit {
	u := &unit{
		id:    id,
		name:  name,
		team:  t,
		level: level,
		game:  g,
	}
	w := g.World()
	u.hp = u.initialHp()
	u.Body = w.AddCircle(
		u.mass(),
		u.radius(),
		fixed.Vector{
			w.FromPixel(posX),
			w.FromPixel(posY),
		},
	)
	return u
}

func (u *unit) Id() int {
	return u.id
}
func (u *unit) Name() string {
	return u.name
}
func (u *unit) Team() Team {
	return u.team
}
func (u *unit) Type() Type {
	return units[u.name]["type"].(Type)
}
func (u *unit) Layer() Layer {
	return units[u.name]["layer"].(Layer)
}

func (u *unit) IsDead() bool {
	return u.hp <= 0
}
func (u *unit) TakeDamage(amount int) {
	u.hp -= amount
}
func (u *unit) Destroy() {
	u.game.World().RemoveBody(u.Body)
}

func (u *unit) Skill() string {
	return units[u.name]["skill"].(string)
}
func (u *unit) CastSkill(posX, posY int) bool {
	panic("not implemented")
}

func (u *unit) mass() fixed.Scalar {
	m := units[u.name]["mass"].(int)
	return fixed.FromInt(m)
}
func (u *unit) radius() fixed.Scalar {
	r := units[u.name]["radius"].(int)
	return u.game.World().FromPixel(r)
}
func (u *unit) initialHp() int {
	switch v := units[u.name]["hp"].(type) {
	case int:
		return v
	case []int:
		return v[u.level]
	}
	panic("invalid hp type")
}
func (u *unit) sight() fixed.Scalar {
	s := units[u.name]["sight"].(int)
	return u.game.World().FromPixel(s)
}
func (u *unit) speed() fixed.Scalar {
	s := units[u.name]["speed"].(int)
	return u.game.World().FromPixel(s)
}
func (u *unit) targetTypes() Types {
	return units[u.name]["targettypes"].(Types)
}
func (u *unit) targetLayers() Layers {
	return units[u.name]["targetlayers"].(Layers)
}
func (u *unit) attackDamage() int {
	switch v := units[u.name]["attackdamage"].(type) {
	case int:
		return v
	case []int:
		return v[u.level]
	}
	panic("invalid attack damage type")
}
func (u *unit) attackRange() fixed.Scalar {
	r := units[u.name]["attackrange"].(int)
	return u.game.World().FromPixel(r)
}
func (u *unit) attackInterval() int {
	return units[u.name]["attackinterval"].(int)
}
func (u *unit) preAttackDelay() int {
	return units[u.name]["preattackdelay"].(int)
}
func (u *unit) bulletLifeTime() int {
	return units[u.name]["bulletlifetime"].(int)
}
func (u *unit) transformDelay() int {
	return units[u.name]["transformdelay"].(int)
}
func (u *unit) canSee(v Unit) bool {
	if v.Type() == Knight {
		return true
	}
	r := u.sight() + u.Radius() + v.Radius()
	return u.squaredDistanceTo(v) < r.Mul(r)
}
func (u *unit) withinRange(v Unit) bool {
	r := u.attackRange() + u.Radius() + v.Radius()
	return u.squaredDistanceTo(v) < r.Mul(r)
}
func (u *unit) findTarget() Unit {
	var filter = func(v Unit) bool {
		if v.Team() == u.Team() {
			return false
		}
		if !u.targetTypes().Contains(v.Type()) {
			return false
		}
		if !u.targetLayers().Contains(v.Layer()) {
			return false
		}
		if !u.canSee(v) {
			return false
		}
		return true
	}
	return u.findNearestUnit(filter)
}

func (u *unit) findNearestUnit(filter func(v Unit) bool) Unit {
	var nearest Unit
	var distance fixed.Scalar
	for _, id := range u.game.UnitIds() {
		v := u.game.FindUnit(id)
		if filter(v) {
			d := u.squaredDistanceTo(v)
			if nearest == nil || d < distance {
				nearest, distance = v, d
			}
		}
	}
	return nearest
}

func (u *unit) squaredDistanceTo(v Unit) fixed.Scalar {
	return u.Position().Sub(v.Position()).LengthSquared()
}
