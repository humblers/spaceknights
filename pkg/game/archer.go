package game

import "github.com/humblers/spaceknights/pkg/fixed"
import "github.com/humblers/spaceknights/pkg/physics"

type archer struct {
	id       int
	team     Team
	level    int
	hp       int
	targetId int
	attack   int // elapsed time since attack start

	game Game
	body physics.Body
}

func newArcher(id int, t Team, level, posX, posY int, g Game) *archer {
	a := &archer{}
	a.id = id
	a.team = t
	a.level = level
	a.hp = a.initialHp()
	a.game = g
	a.body = g.World().AddCircle(
		a.mass(),
		a.radius(),
		fixed.Vector{g.World().FromPixel(posX), g.World().FromPixel(posY)},
	)
	return a
}
func (a *archer) Id() int {
	return a.id
}
func (a *archer) Team() Team {
	return a.team
}
func (a *archer) Radius() fixed.Scalar {
	return a.body.Radius()
}
func (a *archer) Position() fixed.Vector {
	return a.body.Position()
}
func (a *archer) Type() Type {
	return Archer["type"].(Type)
}
func (a *archer) Layer() Layer {
	return Archer["layer"].(Layer)
}
func (a *archer) IsDead() bool {
	return a.hp <= 0
}
func (a *archer) TakeDamage(amount int) {
	a.hp -= amount
}

func (a *archer) targetTypes() Types {
	return Archer["targettypes"].(Types)
}

func (a *archer) targetLayers() Layers {
	return Archer["targetlayers"].(Layers)
}

func (a *archer) sight() fixed.Scalar {
	return a.game.World().FromPixel(Archer["sight"].(int))
}

func (a *archer) initialHp() int {
	return Archer["hp"].([]int)[a.level]
}
func (a *archer) attackRange() fixed.Scalar {
	return a.game.World().FromPixel(Archer["attackrange"].(int))
}

func (a *archer) attackInterval() int {
	return Archer["attackinterval"].(int)
}

func (a *archer) preAttackDelay() int {
	return Archer["preattackdelay"].(int)
}

func (a *archer) damage() int {
	return Archer["damage"].([]int)[a.level]
}
func (a *archer) speed() fixed.Scalar {
	return a.game.World().FromPixel(Archer["speed"].(int))
}

func (a *archer) bulletLifeTime() int {
	return Archer["bulletlifetime"].(int)
}

func (a *archer) mass() fixed.Scalar {
	return fixed.FromInt(Archer["mass"].(int))
}

func (a *archer) radius() fixed.Scalar {
	return a.game.World().FromPixel(Archer["radius"].(int))
}

func (a *archer) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *archer) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *archer) handleAttack() {
	if a.attack == a.preAttackDelay() {
		t := a.target()
		if t != nil && a.withinRange(t) {
			a.fire()
		} else {
			a.attack = 0
			return
		}
	}
	a.attack++
	if a.attack > a.attackInterval() {
		a.attack = 0
	}
}

func (a *archer) fire() {
	b := newBullet(a.targetId, a.bulletLifeTime(), a.damage())
	a.game.AddBullet(b)
}

func (a *archer) Update() {
	if a.attack > 0 {
		a.handleAttack()
	} else {
		t := a.target()
		if t == nil {
			a.findTargetAndDoAction()
		} else {
			if a.withinRange(t) {
				a.handleAttack()
			} else {
				a.findTargetAndDoAction()
			}
		}
	}
}

func (a *archer) findTargetAndDoAction() {
	t := a.findTarget()
	a.setTarget(t)
	if t != nil && a.canSee(t) {
		if a.withinRange(t) {
			a.handleAttack()
		} else {
			a.moveTo(t)
		}
	}
}

func (a *archer) moveTo(u Unit) {
	corner := a.game.Map().FindNextCornerInPath(
		a.Position(),
		u.Position(),
		a.Radius(),
	)
	direction := corner.Sub(a.Position()).Normalized()
	a.body.SetVelocity(direction.Mul(a.speed()))
}

func (a *archer) canSee(u Unit) bool {
	if u.Type() == Knight {
		return true
	}
	r := a.sight() + a.Radius() + u.Radius()
	return a.squaredDistanceTo(u) < r.Mul(r)
}

func (a *archer) withinRange(u Unit) bool {
	r := a.attackRange() + a.Radius() + u.Radius()
	return a.squaredDistanceTo(u) < r.Mul(r)
}

func (a *archer) findTarget() Unit {
	var filter = func(u Unit) bool {
		if u.Team() == a.Team() {
			return false
		}
		if !a.targetTypes().Contains(u.Type()) {
			return false
		}
		if !a.targetLayers().Contains(u.Layer()) {
			return false
		}
		return true
	}
	return a.findNearestUnit(filter)
}

func (a *archer) findNearestUnit(filter func(u Unit) bool) Unit {
	var nearest Unit
	var distance fixed.Scalar
	for _, id := range a.game.UnitIds() {
		u := a.game.FindUnit(id)
		if filter(u) {
			d := a.squaredDistanceTo(u)
			if nearest == nil || d < distance {
				nearest, distance = u, d
			}
		}
	}
	return nearest
}

func (a *archer) squaredDistanceTo(u Unit) fixed.Scalar {
	return a.Position().Sub(u.Position()).LengthSquared()
}
