package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type felhound struct {
	*unit
	targetId int
	attack   int
	shield   int
}

func newFelhound(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "felhound", p.Team(), level, posX, posY, g)
	return &felhound{
		unit:   u,
		shield: u.initialShield(),
	}
}

func (f *felhound) TakeDamage(amount int, a Attacker) {
	if a.DamageType() != data.AntiShield {
		f.shield -= amount
		if f.shield < 0 {
			f.hp += f.shield
			f.shield = 0
		}
	} else {
		f.hp -= amount
	}
}

func (f *felhound) Update() {
	f.unit.Update()
	if f.freeze > 0 {
		f.attack = 0
		f.targetId = 0
		f.freeze--
		return
	}
	if f.attack > 0 {
		f.handleAttack()
	} else {
		t := f.target()
		if t == nil {
			f.findTargetAndDoAction()
		} else {
			if f.withinRange(t) {
				f.handleAttack()
			} else {
				f.findTargetAndDoAction()
			}
		}
	}
	f.shield += ShieldRegenPerStep
	if f.shield > f.initialShield() {
		f.shield = f.initialShield()
	}
}

func (f *felhound) target() Unit {
	return f.game.FindUnit(f.targetId)
}

func (f *felhound) setTarget(u Unit) {
	if u == nil {
		f.targetId = 0
	} else {
		f.targetId = u.Id()
	}
}

func (f *felhound) findTargetAndDoAction() {
	t := f.findTarget()
	f.setTarget(t)
	if t != nil {
		if f.withinRange(t) {
			f.handleAttack()
		} else {
			f.moveTo(t)
		}
	}
}

func (f *felhound) handleAttack() {
	if f.attack == f.preAttackDelay() {
		t := f.target()
		if t != nil && f.withinRange(t) {
			t.TakeDamage(f.attackDamage(), f)
		} else {
			f.attack = 0
			return
		}
	}
	f.attack++
	if f.attack > f.attackInterval() {
		f.attack = 0
	}
}
