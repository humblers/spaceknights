package game

import "github.com/humblers/spaceknights/pkg/fixed"

type ogre struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newOgre(id int, level, posX, posY int, g Game, p Player) Unit {
	return &ogre{
		unit: newUnit(id, "ogre", p.Team(), level, posX, posY, g),
	}
}

func (o *ogre) Update() {
	o.SetVelocity(fixed.Vector{0, 0})
	if o.attack > 0 {
		o.handleAttack()
	} else {
		t := o.target()
		if t == nil {
			o.findTargetAndDoAction()
		} else {
			if o.withinRange(t) {
				o.handleAttack()
			} else {
				o.findTargetAndDoAction()
			}
		}
	}
}

func (o *ogre) target() Unit {
	return o.game.FindUnit(o.targetId)
}

func (o *ogre) setTarget(u Unit) {
	if u == nil {
		o.targetId = 0
	} else {
		o.targetId = u.Id()
	}
}

func (o *ogre) findTargetAndDoAction() {
	t := o.findTarget()
	o.setTarget(t)
	if t != nil {
		if o.withinRange(t) {
			o.handleAttack()
		} else {
			o.moveTo(t)
		}
	}
}

func (o *ogre) moveTo(u Unit) {
	corner := o.game.Map().FindNextCornerInPath(
		o.Position(),
		u.Position(),
		o.Radius(),
	)
	direction := corner.Sub(o.Position()).Normalized()
	o.SetVelocity(direction.Mul(o.speed()))
}

func (o *ogre) handleAttack() {
	if o.attack == o.preAttackDelay() {
		t := o.target()
		if t != nil && o.withinRange(t) {
			t.TakeDamage(o.attackDamage(), Melee)
		} else {
			o.attack = 0
			return
		}
	}
	o.attack++
	if o.attack > o.attackInterval() {
		o.attack = 0
	}
}