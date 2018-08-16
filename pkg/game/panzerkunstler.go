package game

import "github.com/humblers/spaceknights/pkg/fixed"

type panzerkunstler struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newPanzerkunstler(id int, level, posX, posY int, g Game, p Player) Unit {
	return &panzerkunstler{
		unit: newUnit(id, "panzerkunstler", p.Team(), level, posX, posY, g),
	}
}

func (p *panzerkunstler) Update() {
	p.SetVelocity(fixed.Vector{0, 0})
	if p.attack > 0 {
		p.handleAttack()
	} else {
		t := p.target()
		if t == nil {
			p.findTargetAndDoAction()
		} else {
			if p.withinRange(t) {
				p.handleAttack()
			} else {
				p.findTargetAndDoAction()
			}
		}
	}
}

func (p *panzerkunstler) target() Unit {
	return p.game.FindUnit(p.targetId)
}

func (p *panzerkunstler) setTarget(u Unit) {
	if u == nil {
		p.targetId = 0
	} else {
		p.targetId = u.Id()
	}
}

func (p *panzerkunstler) findTargetAndDoAction() {
	t := p.findTarget()
	p.setTarget(t)
	if t != nil {
		if p.withinRange(t) {
			p.handleAttack()
		} else {
			p.moveTo(t)
		}
	}
}

func (p *panzerkunstler) moveTo(u Unit) {
	corner := p.game.Map().FindNextCornerInPath(
		p.Position(),
		u.Position(),
		p.Radius(),
	)
	direction := corner.Sub(p.Position()).Normalized()
	p.SetVelocity(direction.Mul(p.speed()))
}

func (p *panzerkunstler) handleAttack() {
	if p.attack == p.preAttackDelay() {
		t := p.target()
		if t != nil && p.withinRange(t) {
			t.TakeDamage(p.attackDamage(), Melee)
		} else {
			p.attack = 0
			return
		}
	}
	p.attack++
	if p.attack > p.attackInterval() {
		p.attack = 0
	}
}
