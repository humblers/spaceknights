package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type voidcreeper struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newVoidcreeper(id int, level, posX, posY int, g Game, p Player) Unit {
	return &voidcreeper{
		unit: newUnit(id, "voidcreeper", p.Team(), level, posX, posY, g),
	}
}

func (v *voidcreeper) TakeDamage(amount int, damageType data.DamageType) {
	alreadyDead := v.IsDead()
	v.unit.TakeDamage(amount, damageType)
	if !alreadyDead && v.IsDead() {
		for _, id := range v.game.UnitIds() {
			u := v.game.FindUnit(id)
			if u.Team() == v.Team() {
				continue
			}
			d := v.Position().Sub(u.Position()).LengthSquared()
			r := u.Radius().Add(v.destroyRadius())
			if d < r.Mul(r) {
				u.TakeDamage(v.destroyDamage(), v.destroyDamageType())
			}
		}
	}
}

func (v *voidcreeper) Update() {
	v.unit.Update()
	if v.freeze > 0 {
		v.attack = 0
		v.targetId = 0
		v.freeze--
		return
	}
	if v.attack > 0 {
		v.handleAttack()
	} else {
		t := v.target()
		if t == nil {
			v.findTargetAndDoAction()
		} else {
			if v.withinRange(t) {
				v.handleAttack()
			} else {
				v.findTargetAndDoAction()
			}
		}
	}
}

func (v *voidcreeper) target() Unit {
	return v.game.FindUnit(v.targetId)
}

func (v *voidcreeper) setTarget(u Unit) {
	if u == nil {
		v.targetId = 0
	} else {
		v.targetId = u.Id()
	}
}

func (v *voidcreeper) findTargetAndDoAction() {
	t := v.findTarget()
	v.setTarget(t)
	if t != nil {
		if v.withinRange(t) {
			v.handleAttack()
		} else {
			v.moveTo(t)
		}
	}
}

func (v *voidcreeper) handleAttack() {
	if v.attack == v.preAttackDelay() {
		t := v.target()
		if t != nil && v.withinRange(t) {
			for _, id := range v.game.UnitIds() {
				u := v.game.FindUnit(id)
				if u.Team() == v.Team() {
					continue
				}
				d := t.Position().Sub(u.Position()).LengthSquared()
				r := u.Radius().Add(v.damageRadius())
				if d < r.Mul(r) {
					u.TakeDamage(v.attackDamage(), v.damageType())
				}
			}
		} else {
			v.attack = 0
			return
		}
	}
	v.attack++
	if v.attack > v.attackInterval() {
		v.attack = 0
	}
}

func (v *voidcreeper) damageRadius() fixed.Scalar {
	r := data.Units[v.name]["damageradius"].(int)
	return v.game.World().FromPixel(r)
}

func (v *voidcreeper) destroyDamageType() data.DamageType {
	return data.Units[v.name]["destroydamagetype"].(data.DamageType)
}

func (v *voidcreeper) destroyDamage() int {
	return data.Units[v.name]["destroydamage"].([]int)[v.level]
}

func (v *voidcreeper) destroyRadius() fixed.Scalar {
	r := data.Units[v.name]["destroyradius"].(int)
	return v.game.World().FromPixel(r)
}
