package game

type cannon struct {
	*unit
	Decayable
	TileOccupier
	targetId int
	attack   int // elapsed time since attack start
}

func newCannon(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "cannon", p.Team(), level, posX, posY, g)
	c := &cannon{
		unit:         u,
		TileOccupier: newTileOccupier(g),
	}
	c.Decayable = newDecayable(c)
	return c
}

func (c cannon) Destroy() {
	c.unit.Destroy()
	c.Release()
}

func (c cannon) Update() {
	c.TakeDecayDamage()
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

func (c *cannon) setHp(hp int) {
	c.hp = hp
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
	b := newBullet(c.targetId, c.bulletLifeTime(), c.attackDamage())
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
