package game

import "github.com/humblers/spaceknights/pkg/data"

type cannon struct {
	*unit
	Decayable
	targetId int
	attack   int // elapsed time since attack start
}

func newCannon(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "cannon", p.Team(), level, posX, posY, g)
	c := &cannon{
		unit: u,
	}
	c.Decayable = newDecayable(c)
	return c
}

func (c *cannon) TakeDamage(amount int, damageType data.DamageType) {
	if damageType.Is(data.DecreaseOnKnight) {
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	}
	c.unit.TakeDamage(amount, damageType)
}

func (c *cannon) Destroy() {
	c.unit.Destroy()
	c.Release()
}

func (c *cannon) Update() {
	c.TakeDecayDamage()
	if c.freeze > 0 {
		c.attack = 0
		c.targetId = 0
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
}

func (c *cannon) target() Unit {
	return c.game.FindUnit(c.targetId)
}

func (c *cannon) setTarget(u Unit) {
	if u == nil {
		c.targetId = 0
	} else {
		c.targetId = u.Id()
	}
}

func (c *cannon) fire() {
	b := newBullet(c.targetId, c.bulletLifeTime(), c.attackDamage(), c.damageType(), c.game)
	c.game.AddBullet(b)
}

func (c *cannon) findTargetAndDoAction() {
	t := c.findTarget()
	c.setTarget(t)
	if t != nil {
		if c.withinRange(t) {
			c.handleAttack()
		}
	}
}

func (c *cannon) handleAttack() {
	if c.attack == c.preAttackDelay() {
		t := c.target()
		if t != nil && c.withinRange(t) {
			c.fire()
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
