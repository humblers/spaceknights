package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type psabu struct {
	*unit
	player   Player
	targetId int
	attack   int
	shield   int
	punchPos fixed.Vector
}

func newPsabu(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "psabu", p.Team(), level, posX, posY, g)
	return &psabu{
		unit:   u,
		shield: u.initialShield(),
		player: p,
	}
}

func (p *psabu) TakeDamage(amount int, damageType data.DamageType) {
	if damageType != data.AntiShield {
		p.shield -= amount
		if p.shield < 0 {
			p.hp += p.shield
			p.shield = 0
		}
	} else {
		p.hp -= amount
	}
}

func (p *psabu) Update() {
	p.unit.Update()
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
	p.shield += ShieldRegenPerStep
	if p.shield > p.initialShield() {
		p.shield = p.initialShield()
	}
}

func (p *psabu) target() Unit {
	return p.game.FindUnit(p.targetId)
}

func (p *psabu) setTarget(u Unit) {
	if u == nil {
		p.targetId = 0
	} else {
		p.targetId = u.Id()
	}
}

func (p *psabu) findTargetAndDoAction() {
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

func (p *psabu) handleAttack() {
	t := p.target()
	if p.attack == 0 {
		d := t.Position().Sub(p.Position()).Normalized().Mul(p.attackRange())
		p.punchPos = p.Position().Add(d)
	}
	if p.attack < p.preAttackDelay() {
		p.absorb()
	} else if p.attack == p.preAttackDelay() {
		radius := p.attackRadius()
		for _, id := range p.game.UnitIds() {
			u := p.game.FindUnit(id)
			if u.Team() == p.Team() {
				continue
			}
			d := p.punchPos.Sub(u.Position()).LengthSquared()
			r := u.Radius().Add(radius)
			if d < r.Mul(r) {
				u.TakeDamage(p.attackDamage(), p.damageType())
			}
		}
	}
	p.attack++
	if p.attack > p.attackInterval() {
		p.attack = 0
	}
}

func (p *psabu) attackRadius() fixed.Scalar {
	r := data.Units[p.name]["attackradius"].(int)
	return p.game.World().FromPixel(r)
}

func (p *psabu) absorb() {
	absorbRadius := p.game.World().FromPixel(data.Units[p.name]["absorbradius"].(int))
	damageRadius := p.game.World().FromPixel(data.Units[p.name]["absorbdamageradius"].(int))
	force := p.game.World().FromPixel(data.Units[p.name]["absorbforce"].(int))
	damage := data.Units[p.name]["absorbdamage"].(int)
	damageType := data.Units[p.name]["absorbdamagetype"].(data.DamageType)
	for _, id := range p.game.UnitIds() {
		u := p.game.FindUnit(id)
		if u.Team() == p.Team() || u.Layer() != data.Normal {
			continue
		}
		d := p.punchPos.Sub(u.Position())
		r := u.Radius().Add(absorbRadius)
		if d.LengthSquared() < r.Mul(r) {
			n := d.Normalized()
			u.AddForce(n.Mul(force))
		}
		r = u.Radius().Add(damageRadius)
		if d.LengthSquared() < r.Mul(r) {
			u.TakeDamage(damage, damageType)
		}
	}
}
