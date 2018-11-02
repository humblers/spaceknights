package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
	"github.com/humblers/spaceknights/pkg/physics"
)

type Attacker interface {
	DamageType() data.DamageType
}

type Unit interface {
	Id() int
	Name() string
	Team() Team
	Type() data.UnitType
	Layer() data.UnitLayer
	IsDead() bool
	TakeDamage(amount int, t Attacker)
	Update()
	Destroy()
	Freeze(duration int)
	MakeSlow(duration int)

	// from physics.Body
	Position() fixed.Vector
	Radius() fixed.Scalar
	SetPosition(p fixed.Vector)
	SetVelocity(v fixed.Vector)
	AddForce(f fixed.Vector)

	// for caster type
	SetAsLeader()
	Skill() map[string]interface{}
	CastSkill(posX, posY int) bool
}

type unit struct {
	id    int
	name  string
	team  Team
	level int
	hp    int
	game  Game
	physics.Body

	slowUntil int
	freeze    int
}

func (u *unit) MakeSlow(duration int) {
	u.slowUntil = u.game.Step() + duration
}

func (u *unit) Freeze(duration int) {
	if u.Layer() == data.Casting {
		return
	}
	if u.freeze < duration {
		u.freeze = duration
	}
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
	u.setLayer(u.initialLayer())
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
func (u *unit) Type() data.UnitType {
	return data.Units[u.name]["type"].(data.UnitType)
}
func (u *unit) Layer() data.UnitLayer {
	return data.UnitLayer(u.Body.Layer())
}

func (u *unit) IsDead() bool {
	return u.hp <= 0
}

func (u *unit) TakeDamage(amount int, a Attacker) {
	if u.Layer() != data.Normal {
		return
	}
	u.hp -= amount
}
func (u *unit) Destroy() {
	u.game.World().RemoveBody(u.Body)
}

func (u *unit) SetAsLeader() {
	panic("not implemented")
}
func (u *unit) Skill() map[string]interface{} {
	panic("not implemented")
}
func (u *unit) CastSkill(posX, posY int) bool {
	panic("not implemented")
}
func (u *unit) DamageType() data.DamageType {
	return data.Units[u.name]["damagetype"].(data.DamageType)
}
func (u *unit) initialLayer() data.UnitLayer {
	return data.Units[u.name]["layer"].(data.UnitLayer)
}
func (u *unit) setLayer(l data.UnitLayer) {
	if l == data.Casting {
		u.Body.Simulate(false)
	} else {
		u.Body.Simulate(true)
	}
	u.Body.SetLayer(string(l))
}
func (u *unit) mass() fixed.Scalar {
	m := data.Units[u.name]["mass"].(int)
	return fixed.FromInt(m)
}
func (u *unit) radius() fixed.Scalar {
	r := data.Units[u.name]["radius"].(int)
	return u.game.World().FromPixel(r)
}
func (u *unit) initialHp() int {
	switch v := data.Units[u.name]["hp"].(type) {
	case int:
		return v
	case []int:
		return v[u.level]
	}
	panic("invalid hp type")
}
func (u *unit) initialShield() int {
	switch v := data.Units[u.name]["shield"].(type) {
	case int:
		return v
	case []int:
		return v[u.level]
	}
	panic("invalid shield type")
}
func (u *unit) sight() fixed.Scalar {
	s := data.Units[u.name]["sight"].(int)
	return u.game.World().FromPixel(s)
}
func (u *unit) speed() fixed.Scalar {
	s := data.Units[u.name]["speed"].(int)
	if u.slowUntil >= u.game.Step() {
		s = s * SlowPercent / 100
	}
	return u.game.World().FromPixel(s)
}
func (u *unit) targetTypes() data.UnitTypes {
	return data.Units[u.name]["targettypes"].(data.UnitTypes)
}
func (u *unit) targetLayers() data.UnitLayers {
	return data.Units[u.name]["targetlayers"].(data.UnitLayers)
}
func (u *unit) attackDamage() int {
	switch v := data.Units[u.name]["attackdamage"].(type) {
	case int:
		return v
	case []int:
		return v[u.level]
	}
	panic("invalid attack damage type")
}
func (u *unit) attackRange() fixed.Scalar {
	r := data.Units[u.name]["attackrange"].(int)
	return u.game.World().FromPixel(r)
}
func (u *unit) attackInterval() int {
	i := data.Units[u.name]["attackinterval"].(int)
	if u.slowUntil >= u.game.Step() {
		i = i * 100 / SlowPercent
	}
	return i
}
func (u *unit) preAttackDelay() int {
	return data.Units[u.name]["preattackdelay"].(int)
}
func (u *unit) bulletLifeTime() int {
	return data.Units[u.name]["bulletlifetime"].(int)
}
func (u *unit) canSee(v Unit) bool {
	if v.Type() == data.Knight {
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

func (u *unit) moveToPos(pos fixed.Vector) {
	v := pos.Sub(u.Position()).Truncated(u.speed())
	u.SetVelocity(v)
}
