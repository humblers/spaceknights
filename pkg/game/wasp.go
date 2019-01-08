package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type wasp struct {
	*unit
	targetId int
	attack   int
	shield   int
}

func newWasp(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "wasp", p.Team(), level, posX, posY, g)
	return &wasp{
		unit:   u,
		shield: u.initialShield(),
	}
}

func (w *wasp) TakeDamage(amount int, damageType data.DamageType) {
	alreadyDead := w.IsDead()
	if damageType.Is(data.AntiShield) {
		w.shield -= amount
		if w.shield < 0 {
			w.hp += w.shield
			w.shield = 0
		}
	} else {
		w.hp -= amount
	}
	if !alreadyDead && w.IsDead() {
		for _, id := range w.game.UnitIds() {
			u := w.game.FindUnit(id)
			if u.Team() == w.Team() {
				continue
			}
			d := w.Position().Sub(u.Position()).LengthSquared()
			r := u.Radius().Add(w.destroyRadius())
			if d < r.Mul(r) {
				u.TakeDamage(w.destroyDamage(), w.destroyDamageType())
			}
		}
	}
}

func (w *wasp) Update() {
	w.unit.Update()
	if w.freeze > 0 {
		w.attack = 0
		w.targetId = 0
		w.freeze--
		return
	}
	if w.attack > 0 {
		w.handleAttack()
	} else {
		t := w.target()
		if t == nil {
			w.findTargetAndDoAction()
		} else {
			if w.withinRange(t) {
				w.handleAttack()
			} else {
				w.findTargetAndDoAction()
			}
		}
	}
}

func (w *wasp) target() Unit {
	return w.game.FindUnit(w.targetId)
}

func (w *wasp) setTarget(u Unit) {
	if u == nil {
		w.targetId = 0
	} else {
		w.targetId = u.Id()
	}
}

func (w *wasp) findTargetAndDoAction() {
	t := w.findTarget()
	w.setTarget(t)
	if t != nil {
		if w.withinRange(t) {
			w.handleAttack()
		} else {
			w.moveTo(t)
		}
	}
}

func (w *wasp) handleAttack() {
	if w.attack == w.preAttackDelay() {
		t := w.target()
		if t != nil && w.withinRange(t) {
			t.TakeDamage(w.attackDamage(), w.damageType())
		} else {
			w.attack = 0
			return
		}
	}
	w.attack++
	if w.attack > w.attackInterval() {
		w.attack = 0
	}
}

func (w *wasp) destroyDamageType() data.DamageType {
	return data.Units[w.name]["destroydamagetype"].(data.DamageType)
}

func (w *wasp) destroyDamage() int {
	return data.Units[w.name]["destroydamage"].([]int)[w.level]
}

func (w *wasp) destroyRadius() fixed.Scalar {
	r := data.Units[w.name]["destroyradius"].(int)
	return w.game.World().FromPixel(r)
}
