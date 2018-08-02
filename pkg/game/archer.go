package game

import "github.com/humblers/spaceknights/pkg/fixed"

type archer struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newArcher(id int, level, posX, posY int, g Game, p Player) Unit {
	return &archer{
		unit: newUnit(id, "archer", p.Team(), level, posX, posY, g),
	}
}

func (a *archer) Update() {
	a.SetVelocity(fixed.Vector{0, 0})
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

func (a *archer) fire() {
	b := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage())
	a.game.AddBullet(b)
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
	a.SetVelocity(direction.Mul(a.speed()))
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
