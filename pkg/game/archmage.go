package game

import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type archmage struct {
	*unit
	player   Player
	targetId int
	attack   int // elapsed time since attack start
}

func newArchmage(id int, level, posX, posY int, g Game, p Player) Unit {
	return &archmage{
		unit:   newUnit(id, "archmage", p.Team(), level, posX, posY, g),
		player: p,
	}
}

func (a *archmage) Update() {
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

func (a *archmage) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *archmage) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *archmage) fire() {
	bullet := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage(), a.damageType(), a.game)
	bullet.MakeSplash(a.damageRadius())
	a.game.AddBullet(bullet)
}

func (a *archmage) findTargetAndDoAction() {
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

func (a *archmage) handleAttack() {
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

func (a *archmage) damageRadius() fixed.Scalar {
	r := data.Units[a.name]["damageradius"].(int)
	return a.game.World().FromPixel(r)
}
