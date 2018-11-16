package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type pixie struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newPixie(id int, level, posX, posY int, g Game, p Player) Unit {
	return &pixie{
		unit: newUnit(id, "pixie", p.Team(), level, posX, posY, g),
	}
}

func (p *pixie) Update() {
	p.SetVelocity(fixed.Vector{0, 0})
	if p.freeze > 0 {
		p.attack = 0
		p.targetId = 0
		p.freeze--
		return
	}
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

func (p *pixie) target() Unit {
	return p.game.FindUnit(p.targetId)
}

func (p *pixie) setTarget(u Unit) {
	if u == nil {
		p.targetId = 0
	} else {
		p.targetId = u.Id()
	}
}

func (p *pixie) findTargetAndDoAction() {
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

func (p *pixie) handleAttack() {
	if p.attack == 0 {
		p.setLayer(data.Normal)
	}
	if p.attack == p.preAttackDelay() {
		t := p.target()
		if t != nil && p.withinRange(t) {
			t.TakeDamage(p.attackDamage(), p)
		} else {
			p.attack = 0
			p.setLayer(p.initialLayer())
			return
		}
	}
	p.attack++
	if p.attack > p.attackInterval() {
		p.attack = 0
		p.setLayer(p.initialLayer())
	}
}
