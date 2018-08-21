package game

import "github.com/humblers/spaceknights/pkg/fixed"

type psabu struct {
	*unit
	targetId int
	attack   int
	shield   int
	punchPos fixed.Vector
}

func newPsabu(id int, level, posX, posY int, g Game, p Player) Unit {
	return &psabu{
		unit: newUnit(id, "psabu", p.Team(), level, posX, posY, g),
	}
}

func (p *psabu) TakeDamage(amount int, t AttackType) {
	if t != Melee {
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

func (p *psabu) moveTo(u Unit) {
	corner := p.game.Map().FindNextCornerInPath(
		p.Position(),
		u.Position(),
		p.Radius(),
	)
	direction := corner.Sub(p.Position()).Normalized()
	p.SetVelocity(direction.Mul(p.speed()))
}

func (p *psabu) handleAttack() {
	t := p.target()
	if p.attack == 0 {
		r := p.Radius().Add(p.attackRange())
		d := t.Position().Sub(p.Position()).Normalized().Mul(r)
		p.punchPos = p.Position().Add(d)
	}
	if p.attack < p.preAttackDelay() {
		p.absorb()
	} else if p.attack == p.preAttackDelay() {
		radius := p.game.World().FromPixel(units[p.name]["attackradius"].(int))
		for _, id := range p.game.UnitIds() {
			u := p.game.FindUnit(id)
			if u.Team() == p.Team() {
				continue
			}
			d := p.punchPos.Sub(u.Position()).LengthSquared()
			r := u.Radius().Add(radius)
			if d < r.Mul(r) {
				u.TakeDamage(p.attackDamage(), Melee)
			}
		}
	}
	p.attack++
	if p.attack > p.attackInterval() {
		p.attack = 0
	}
}

func (p *psabu) absorb() {
	radius := p.game.World().FromPixel(units[p.name]["absorbradius"].(int))
	force := p.game.World().FromPixel(units[p.name]["absorbforce"].(int))
	damage := units[p.name]["absorbdamage"].(int)
	for _, id := range p.game.UnitIds() {
		u := p.game.FindUnit(id)
		if u.Team() == p.Team() || u.Layer() != Normal {
			continue
		}
		d := p.punchPos.Sub(u.Position())
		r := u.Radius().Add(radius)
		if d.LengthSquared() < r.Mul(r) {
			n := d.Normalized()
			u.AddForce(n.Mul(force))
			u.TakeDamage(damage, Skill)
		}
	}
}
