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
	return &panzerkunstler{
		unit:   newUnit(id, "panzerkunstler", p.Team(), level, posX, posY, g),
		player: p,
	}
}

func (p *panzerkunstler) Update() {
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
	if p.canDoPowerAttack() {
		if p.attack == 0 {
			t := p.target()
			r := p.Radius().Add(p.attackRange())
			d := t.Position().Sub(p.Position()).Normalized().Mul(r)
			p.punchPos = p.Position().Add(d)
		}
		if p.attack >= p.powerAttackPreDelay() {
			for _, id := range p.game.UnitIds() {
				u := p.game.FindUnit(id)
				if u.Team() == p.Team() || u.Layer() != data.Normal {
					continue
				}
				d := u.Position().Sub(p.punchPos)
				r := u.Radius().Add(p.powerAttackRadius())
				if d.LengthSquared() < r.Mul(r) {
					n := d.Normalized()
					u.AddForce(n.Mul(p.powerAttackForce()))
					if p.attack == p.powerAttackPreDelay() {
						u.TakeDamage(p.powerAttackDamage(), p)
					}
				}
			}
		}
		p.attack++
		if p.attack > p.powerAttackInterval() {
			p.attack = 0
			p.attackCount++
		}
	} else {
		if p.attack == p.preAttackDelay() {
			t := p.target()
			if t != nil && p.withinRange(t) {
				t.TakeDamage(p.attackDamage(), p)
			} else {
				p.attack = 0
				return
			}
		}
		p.attack++
		if p.attack > p.attackInterval() {
			p.attack = 0
			p.attackCount++
		}
	}
}

func (p *panzerkunstler) canDoPowerAttack() bool {
	return p.attackCount%p.powerAttackFrequency() == 0
}

func (p *panzerkunstler) powerAttackInterval() int {
	return data.Units[p.name]["powerattackinterval"].(int)
}

func (p *panzerkunstler) powerAttackPreDelay() int {
	return data.Units[p.name]["powerattackpredelay"].(int)
}

func (p *panzerkunstler) powerAttackFrequency() int {
	return data.Units[p.name]["powerattackfrequency"].(int)
}

func (p *panzerkunstler) powerAttackDamage() int {
	switch v := data.Units[p.name]["powerattackdamage"].(type) {
	case int:
		return v
	case []int:
		return v[p.level]
	}
	panic("invalid power attack damage type")
}

func (p *panzerkunstler) powerAttackRadius() fixed.Scalar {
	r := data.Units[p.name]["powerattackradius"].(int)
	divider := 1
	for _, ratio := range p.player.StatRatios("arearatio") {
		r *= ratio
		divider *= 100
	}
	return p.game.World().FromPixel(r / divider)
}

func (p *panzerkunstler) powerAttackForce() fixed.Scalar {
	return p.game.World().FromPixel(data.Units[p.name]["powerattackforce"].(int))
}
