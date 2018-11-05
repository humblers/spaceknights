package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type champion struct {
	*unit
	targetId int
	attack   int
	charge   int
	shield   int
}

func newChampion(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "champion", p.Team(), level, posX, posY, g)
	return &champion{
		unit:   u,
		shield: u.initialShield(),
	}
}

func (c *champion) TakeDamage(amount int, a Attacker) {
	if a.DamageType() != data.AntiShield {
		c.shield -= amount
		if c.shield < 0 {
			c.hp += c.shield
			c.shield = 0
		}
	} else {
		c.hp -= amount
	}
}

func (c *champion) Update() {
	c.SetVelocity(fixed.Vector{0, 0})
	if c.freeze > 0 {
		c.attack = 0
		c.targetId = 0
		c.charge = 0
		c.freeze--
		return
	}
	if c.attack > 0 {
		c.handleAttack()
	} else {
		t := c.target()
		if t == nil {
			c.findTargetAndDoAction()
		} else {
			if c.withinRange(t) {
				c.handleAttack()
			} else {
				c.findTargetAndDoAction()
			}
		}
	}
	c.shield += ShieldRegenPerStep
	if c.shield > c.initialShield() {
		c.shield = c.initialShield()
	}
}

func (c *champion) target() Unit {
	return c.game.FindUnit(c.targetId)
}

func (c *champion) setTarget(u Unit) {
	if u == nil {
		c.targetId = 0
	} else {
		c.targetId = u.Id()
	}
}

func (c *champion) findTargetAndDoAction() {
	t := c.findTarget()
	c.setTarget(t)
	if t != nil {
		if c.withinRange(t) {
			c.handleAttack()
		} else {
			c.moveTo(t)
		}
	} else {
		c.charge = 0
	}
}

func (c *champion) moveTo(u Unit) {
	corner := c.game.Map().FindNextCornerInPath(
		c.Position(),
		u.Position(),
		c.Radius(),
	)
	direction := corner.Sub(c.Position()).Normalized()
	speed := c.speed()
	if c.charged() {
		speed = c.chargedMoveSpeed()
	}
	c.SetVelocity(direction.Mul(speed))
	c.charge++
}

func (c *champion) handleAttack() {
	if c.charged() {
		if c.attack == c.chargedAttackPreDelay() {
			t := c.target()
			if t != nil && c.withinRange(t) {
				t.TakeDamage(c.chargedAttackDamage(), c)
			} else {
				c.attack = 0
				c.charge = 0
				return
			}
		}
		c.attack++
		if c.attack > c.chargedAttackInterval() {
			c.attack = 0
			c.charge = 0
		}
	} else {
		c.charge = 0
		if c.attack == c.preAttackDelay() {
			t := c.target()
			if t != nil && c.withinRange(t) {
				t.TakeDamage(c.attackDamage(), c)
			} else {
				c.attack = 0
				return
			}
		}
		c.attack++
		if c.attack > c.attackInterval() {
			c.attack = 0
		}
	}
}

func (c *champion) chargeDelay() int {
	return data.Units[c.name]["chargedelay"].(int)
}

func (c *champion) chargedMoveSpeed() fixed.Scalar {
	s := data.Units[c.name]["chargedmovespeed"].(int)
	return c.game.World().FromPixel(s)
}

func (c *champion) chargedAttackDamage() int {
	switch v := data.Units[c.name]["chargedattackdamage"].(type) {
	case int:
		return v
	case []int:
		return v[c.level]
	}
	panic("invalid charged attack damage type")
}

func (c *champion) chargedAttackInterval() int {
	return data.Units[c.name]["chargedattackinterval"].(int)
}

func (c *champion) chargedAttackPreDelay() int {
	return data.Units[c.name]["chargedattackpredelay"].(int)
}

func (c *champion) charged() bool {
	return c.charge >= c.chargeDelay()
}
