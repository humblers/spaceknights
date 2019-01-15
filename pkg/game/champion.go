package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type champion struct {
	*unit
	player   Player
	targetId int
	attack   int
	charge   int
	shield   int
}

func newChampion(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "champion", p.Team(), level, posX, posY, g)
	return &champion{
		unit:   u,
		player: p,
		shield: u.initialShield(),
	}
}

func (c *champion) TakeDamage(amount int, damageType data.DamageType) {
	if damageType.Is(data.AntiShield) {
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
	c.unit.Update()
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
	var pos fixed.Vector
	if c.Layer() == data.Ether {
		pos = u.Position().Sub(c.Position())
	} else {
		corner := c.game.Map().FindNextCornerInPath(
			c.Position(),
			u.Position(),
			c.Radius(),
		)
		pos = corner.Sub(c.Position())
	}
	direction := pos.Normalized()
	speed := c.speed()
	desired_vel := direction.Mul(speed)
	desired_pos := c.Position().Add(desired_vel.Mul(c.game.World().Dt()))
	if c.Colliding() && c.moving {
		diff := c.prev_desired_pos.Sub(c.Position())
		l := diff.Length()
		adjust_ratio := l.Div(speed.Mul(c.game.World().Dt())).Clamp(0, fixed.One)
		var to fixed.Vector
		if diff.X < 0 {
			to = fixed.Vector{-desired_vel.Y, desired_vel.X}
		} else {
			to = fixed.Vector{desired_vel.Y, -desired_vel.X}
		}
		desired_vel = desired_vel.Add(to.Mul(adjust_ratio)).Truncated(speed)
	}
	c.SetPosition(desired_pos)
	c.prev_desired_pos = desired_pos
	c.moving = true
	c.charge++
}

func (c *champion) handleAttack() {
	if c.charged() {
		if c.attack == c.chargedAttackPreDelay() {
			t := c.target()
			if t != nil && c.withinRange(t) {
				c.splashAttack(t, c.chargedAttackDamage(), c.chargedAttackDamageType())
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
				c.splashAttack(t, c.attackDamage(), c.damageType())
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

func (c *champion) splashAttack(target Unit, damage int, damageType data.DamageType) {
	for _, id := range c.game.UnitIds() {
		u := c.game.FindUnit(id)
		if u.Team() == c.Team() {
			continue
		}
		d := target.Position().Sub(u.Position()).LengthSquared()
		r := u.Radius().Add(c.damageRadius())
		if d < r.Mul(r) {
			u.TakeDamage(damage, damageType)
		}
	}
}

func (c *champion) chargeDelay() int {
	return data.Units[c.name]["chargedelay"].(int)
}

func (c *champion) speed() fixed.Scalar {
	var s int
	if c.charged() {
		s = data.Units[c.name]["chargedmovespeed"].(int)
	} else {
		s = data.Units[c.name]["speed"].(int)
	}
	if c.slowUntil >= c.game.Step() {
		s = s * SlowPercent / 100
	}
	return c.game.World().FromPixel(s)
}

func (c *champion) chargedAttackDamageType() data.DamageType {
	return data.Units[c.name]["chargedattackdamagetype"].(data.DamageType)
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

func (c *champion) damageRadius() fixed.Scalar {
	r := data.Units[c.name]["damageradius"].(int)
	return c.game.World().FromPixel(r)
}
