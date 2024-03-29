package game

import (
	"github.com/humblers/spaceknights/pkg/data"
)

type gargoyleking struct {
	*unit
	targetId int
	attack   int
	shield   int
}

func newGargoyleking(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "gargoyleking", p.Team(), level, posX, posY, g)
	return &gargoyleking{
		unit:   u,
		shield: u.initialShield(),
	}
}

func (g *gargoyleking) TakeDamage(amount int, damageType data.DamageType) {
	if !damageType.Is(data.AntiShield) {
		g.shield -= amount
		if g.shield < 0 {
			g.hp += g.shield
			g.shield = 0
		}
	} else {
		g.hp -= amount
	}
}

func (g *gargoyleking) Update() {
	g.unit.Update()
	if g.freeze > 0 {
		g.attack = 0
		g.targetId = 0
		g.freeze--
		return
	}
	if g.attack > 0 {
		g.handleAttack()
	} else {
		t := g.target()
		if t == nil {
			g.findTargetAndDoAction()
		} else {
			if g.withinRange(t) {
				g.handleAttack()
			} else {
				g.findTargetAndDoAction()
			}
		}
	}
	g.shield += ShieldRegenPerStep
	if g.shield > g.initialShield() {
		g.shield = g.initialShield()
	}
}

func (g *gargoyleking) target() Unit {
	return g.game.FindUnit(g.targetId)
}

func (g *gargoyleking) setTarget(u Unit) {
	if u == nil {
		g.targetId = 0
	} else {
		g.targetId = u.Id()
	}
}

func (g *gargoyleking) findTargetAndDoAction() {
	t := g.findTarget()
	g.setTarget(t)
	if t != nil {
		if g.withinRange(t) {
			g.handleAttack()
		} else {
			g.moveTo(t)
		}
	}
}

func (g *gargoyleking) handleAttack() {
	if g.attack == g.preAttackDelay() {
		t := g.target()
		if t != nil && g.withinRange(t) {
			t.TakeDamage(g.attackDamage(), g.damageType())
		} else {
			g.attack = 0
			return
		}
	}
	g.attack++
	if g.attack > g.attackInterval() {
		g.attack = 0
	}
}
