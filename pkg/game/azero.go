package game

import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type azero struct {
	*unit
	player   Player
	targetId int
	attack   int // elapsed time since attack start
}

func newAzero(id int, level, posX, posY int, g Game, p Player) Unit {
	return &azero{
		unit:   newUnit(id, "azero", p.Team(), level, posX, posY, g),
		player: p,
	}
}

func (a *azero) Update() {
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

func (a *azero) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *azero) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *azero) fire() {
	bullet := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage(), a.damageType(), a.game)
	bullet.MakeSplash(a.damageRadius())
	bullet.MakeFrozen(a.slowDuration())
	a.game.AddBullet(bullet)
}

func (a *azero) findTargetAndDoAction() {
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

func (a *azero) handleAttack() {
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

func (a *azero) damageRadius() fixed.Scalar {
	r := data.Units[a.name]["damageradius"].(int)
	return a.game.World().FromPixel(r)
}

func (a *azero) slowDuration() int {
	return data.Units[a.name]["slowduration"].(int)
}
