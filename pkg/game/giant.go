package game

import "github.com/humblers/spaceknights/pkg/fixed"

type giant struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newGiant(id int, level, posX, posY int, g Game, p Player) Unit {
	return &giant{
		unit: newUnit(id, "giant", p.Team(), level, posX, posY, g),
	}
}

func (g *giant) Update() {
	g.SetVelocity(fixed.Vector{0, 0})
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
}

func (g *giant) target() Unit {
	return g.game.FindUnit(g.targetId)
}

func (g *giant) setTarget(u Unit) {
	if u == nil {
		g.targetId = 0
	} else {
		g.targetId = u.Id()
	}
}

func (g *giant) findTargetAndDoAction() {
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

func (g *giant) moveTo(u Unit) {
	corner := g.game.Map().FindNextCornerInPath(
		g.Position(),
		u.Position(),
		g.Radius(),
	)
	direction := corner.Sub(g.Position()).Normalized()
	g.SetVelocity(direction.Mul(g.speed()))
}

func (g *giant) handleAttack() {
	if g.attack == g.preAttackDelay() {
		t := g.target()
		if t != nil && g.withinRange(t) {
			t.TakeDamage(g.attackDamage(), Melee)
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