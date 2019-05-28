package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type panzerkunstler struct {
	*unit
	player      Player
	targetId    int
	attack      int // elapsed time since attack start
	attackCount int
	punchPos    fixed.Vector
}

func newPanzerkunstler(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "panzerkunstler", p.Team(), level, posX, posY, g)
	return &panzerkunstler{
		unit:   u,
		player: p,
	}
}

func (p *panzerkunstler) Update() {
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

func (p *panzerkunstler) handleAttack() {
	if p.attack == 0 {
		t := p.target()
		d := t.Position().Sub(p.Position()).Normalized().Mul(p.attackRange())
		p.punchPos = p.Position().Add(d)
	}
	if p.attack >= p.preAttackDelay() {
		for _, id := range p.game.UnitIds() {
			u := p.game.FindUnit(id)
			if u.Team() == p.Team() || u.Layer() != data.Normal {
				continue
			}
			d := u.Position().Sub(p.punchPos)
			r := u.Radius().Add(p.attackRadius())
			if d.LengthSquared() < r.Mul(r) {
				n := d.Normalized()
				u.AddForce(n.Mul(p.attackForce()))
			}
			r = u.Radius().Add(p.attackDamageRadius())
			if d.LengthSquared() < r.Mul(r) && p.attack == p.preAttackDelay() {
				u.TakeDamage(p.attackDamage(), p.damageType())
			}
		}
	}
	p.attack++
	if p.attack > p.attackInterval() {
		p.attack = 0
		p.attackCount++
	}
}

func (p *panzerkunstler) attackDamageRadius() fixed.Scalar {
	r := data.Units[p.name]["attackdamageradius"].(int)
	return p.game.World().FromPixel(r)
}

func (p *panzerkunstler) attackRadius() fixed.Scalar {
	r := data.Units[p.name]["attackradius"].(int)
	return p.game.World().FromPixel(r)
}

func (p *panzerkunstler) attackForce() fixed.Scalar {
	return p.game.World().FromPixel(data.Units[p.name]["attackforce"].(int))
}
