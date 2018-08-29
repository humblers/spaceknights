package game

import "github.com/humblers/spaceknights/pkg/fixed"

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

func (w *wasp) TakeDamage(amount int, t AttackType) {
	if t != Melee {
		w.shield -= amount
		if w.shield < 0 {
			w.hp += w.shield
			w.shield = 0
		}
	} else {
		w.hp -= amount
	}
}

func (w *wasp) Destroy() {
	w.unit.Destroy()
	for _, id := range w.game.UnitIds() {
		u := w.game.FindUnit(id)
		if u.Team() == w.Team() {
			continue
		}
		d := w.Position().Sub(u.Position()).LengthSquared()
		r := w.Radius().Add(u.Radius()).Add(w.destroyRadius())
		if d < r.Mul(r) {
			u.TakeDamage(w.destroyDamage(), Melee)
		}
	}
}

func (w *wasp) Update() {
	w.SetVelocity(fixed.Vector{0, 0})
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

func (w *wasp) moveTo(u Unit) {
	corner := w.game.Map().FindNextCornerInPath(
		w.Position(),
		u.Position(),
		w.Radius(),
	)
	direction := corner.Sub(w.Position()).Normalized()
	w.SetVelocity(direction.Mul(w.speed()))
}

func (w *wasp) handleAttack() {
	if w.attack == w.preAttackDelay() {
		t := w.target()
		if t != nil && w.withinRange(t) {
			t.TakeDamage(w.attackDamage(), Melee)
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

func (w *wasp) destroyDamage() int {
	return units[w.name]["destroydamage"].([]int)[w.level]
}

func (w *wasp) destroyRadius() fixed.Scalar {
	r := units[w.name]["destroyradius"].(int)
	return w.game.World().FromPixel(r)
}
