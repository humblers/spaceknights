package game

import "github.com/humblers/spaceknights/pkg/fixed"

type enforcer struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newEnforcer(id int, level, posX, posY int, g Game, p Player) Unit {
	return &enforcer{
		unit: newUnit(id, "enforcer", p.Team(), level, posX, posY, g),
	}
}

func (e *enforcer) Update() {
	e.SetVelocity(fixed.Vector{0, 0})
	if e.attack > 0 {
		e.handleAttack()
	} else {
		t := e.target()
		if t == nil {
			e.findTargetAndDoAction()
		} else {
			if e.withinRange(t) {
				e.handleAttack()
			} else {
				e.findTargetAndDoAction()
			}
		}
	}
}

func (e *enforcer) target() Unit {
	return e.game.FindUnit(e.targetId)
}

func (e *enforcer) setTarget(u Unit) {
	if u == nil {
		e.targetId = 0
	} else {
		e.targetId = u.Id()
	}
}

func (e *enforcer) findTargetAndDoAction() {
	t := e.findTarget()
	e.setTarget(t)
	if t != nil {
		if e.withinRange(t) {
			e.handleAttack()
		} else {
			e.moveTo(t)
		}
	}
}

func (e *enforcer) moveTo(u Unit) {
	corner := e.game.Map().FindNextCornerInPath(
		e.Position(),
		u.Position(),
		e.Radius(),
	)
	direction := corner.Sub(e.Position()).Normalized()
	e.SetVelocity(direction.Mul(e.speed()))
}

func (e *enforcer) handleAttack() {
	if e.attack == e.preAttackDelay() {
		t := e.target()
		if t != nil && e.withinRange(t) {
			for _, id := range e.game.UnitIds() {
				u := e.game.FindUnit(id)
				if !e.canAttack(u) {
					continue
				}
				d := e.Position().Sub(u.Position()).LengthSquared()
				r := e.Radius().Add(u.Radius()).Add(e.attackRange())
				if d < r.Mul(r) {
					u.TakeDamage(e.attackDamage(), Melee)
				}
			}
		} else {
			e.attack = 0
			return
		}
	}
	e.attack++
	if e.attack > e.attackInterval() {
		e.attack = 0
	}
}

func (e *enforcer) canAttack(u Unit) bool {
	if e.Team() == u.Team() {
		return false
	}
	if !e.targetTypes().Contains(u.Type()) {
		return false
	}
	return true
}
