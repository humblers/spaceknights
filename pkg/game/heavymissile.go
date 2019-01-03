package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type heavymissile struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newHeavymissile(id int, level, posX, posY int, g Game, p Player) Unit {
	return &heavymissile{
		unit: newUnit(id, "heavymissile", p.Team(), level, posX, posY, g),
	}
}

func (h *heavymissile) TakeDamge(amount int, damageType data.DamageType) {
	alreadyDead := h.IsDead()
	h.unit.TakeDamage(amount, damageType)
	if !alreadyDead && h.IsDead() && h.attack > 0 && h.attack <= h.preAttackDelay() {
		h.suicideAttack()
		h.attack = h.preAttackDelay() + 1
	}
}

func (h *heavymissile) Update() {
	h.unit.Update()
	if h.attack > 0 {
		h.handleAttack()
	} else {
		if h.freeze > 0 {
			h.targetId = 0
			h.freeze--
			return
		}
		t := h.target()
		if t == nil {
			h.findTargetAndDoAction()
		} else {
			if h.withinRange(t) {
				h.handleAttack()
			} else {
				h.findTargetAndDoAction()
			}
		}
	}
}

func (h *heavymissile) target() Unit {
	return h.game.FindUnit(h.targetId)
}

func (h *heavymissile) setTarget(u Unit) {
	if u == nil {
		h.targetId = 0
	} else {
		h.targetId = u.Id()
	}
}

func (h *heavymissile) findTargetAndDoAction() {
	t := h.findTarget()
	h.setTarget(t)
	if t != nil {
		if h.withinRange(t) {
			h.handleAttack()
		} else {
			h.moveTo(t)
		}
	}
}

func (h *heavymissile) suicideAttack() {
	for _, id := range h.game.UnitIds() {
		u := h.game.FindUnit(id)
		if u.Team() == h.Team() {
			continue
		}
		d := h.Position().Sub(u.Position()).LengthSquared()
		r := u.Radius().Add(h.attackRadius())
		if d < r.Mul(r) {
			u.TakeDamage(h.attackDamage(), h.damageType())
		}
	}
	if !h.IsDead() {
		h.hp = 0
	}
}

func (h *heavymissile) handleAttack() {
	if h.attack == h.preAttackDelay() {
		h.suicideAttack()
	}
	h.attack++
}

func (h *heavymissile) attackRadius() fixed.Scalar {
	r := data.Units[h.name]["attackradius"].(int)
	return h.game.World().FromPixel(r)
}
