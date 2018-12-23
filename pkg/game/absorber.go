package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type absorber struct {
	*unit
	player   Player
	targetId int
	attack   int // elapsed time since attack start
}

func newAbsorber(id int, level, posX, posY int, g Game, p Player) Unit {
	return &absorber{
		unit:   newUnit(id, "absorber", p.Team(), level, posX, posY, g),
		player: p,
	}
}

func (a *absorber) Update() {
	a.unit.Update()
	if a.freeze > 0 {
		a.attack = 0
		a.targetId = 0
		a.freeze--
		return
	}
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

func (a *absorber) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *absorber) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *absorber) findTargetAndDoAction() {
	t := a.findTarget()
	a.setTarget(t)
	if t != nil {
		if a.withinRange(t) {
			a.handleAttack()
		} else {
			a.moveTo(t)
		}
	}
}

func (a *absorber) handleAttack() {
	if a.attack == a.preAttackDelay() {
		t := a.target()
		if t != nil && a.withinRange(t) {
			for _, id := range a.game.UnitIds() {
				u := a.game.FindUnit(id)
				if !a.canAttack(u) {
					continue
				}
				d := a.Position().Sub(u.Position()).LengthSquared()
				r := a.Radius().Add(u.Radius()).Add(a.attackRadius())
				if d < r.Mul(r) {
					u.TakeDamage(a.attackDamage(), a)
				}
			}
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

func (a *absorber) canAttack(u Unit) bool {
	if a.Team() == u.Team() {
		return false
	}
	if !a.targetTypes().Contains(u.Type()) {
		return false
	}
	return true
}

func (a *absorber) attackRadius() fixed.Scalar {
	r := data.Units[a.name]["attackradius"].(int)
	divider := 1
	for _, ratio := range a.player.StatRatios("arearatio") {
		r *= ratio
		divider *= 100
	}
	return a.game.World().FromPixel(r / divider)
}
