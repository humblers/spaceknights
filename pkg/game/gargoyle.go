package game

import (
	"github.com/humblers/spaceknights/pkg/data"
)

type gargoyle struct {
	*unit
	targetId int
	attack   int
	shield   int
}

func newGargoyle(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "gargoyle", p.Team(), level, posX, posY, g)
	return &gargoyle{
		unit:   u,
		shield: u.initialShield(),
	}
}

func (g *gargoyle) TakeDamage(amount int, damageType data.DamageType) {
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

func (g *gargoyle) Update() {
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

func (g *gargoyle) target() Unit {
	return g.game.FindUnit(g.targetId)
}

func (g *gargoyle) setTarget(u Unit) {
	if u == nil {
		g.targetId = 0
	} else {
		g.targetId = u.Id()
	}
}

func (g *gargoyle) findTargetAndDoAction() {
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

func (g *gargoyle) handleAttack() {
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
