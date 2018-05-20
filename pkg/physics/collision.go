package physics

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

var (
	penetrationPercent = fixed.One.Div(fixed.FromInt(5))   // 0.2
	penetrationSlop    = fixed.One.Div(fixed.FromInt(100)) // 0.01
)

type collision struct {
	a           *body
	b           *body
	normal      fixed.Vec2
	penetration fixed.Number
}

func newCollision(a, b *body) *collision {
	return &collision{
		a: a,
		b: b,
	}
}

func checkCollision(a, b Body) *collision {
	switch a.(type) {
	case box:
		switch b.(type) {
		case box:
			return boxVSbox(a.(*box), b.(*box))
		case circle:
			return boxVScircle(a.(*box), b.(*circle))
		}
	case circle:
		switch b.(type) {
		case box:
			return boxVScircle(b.(*box), a.(*circle))
		case circle:
			return circleVScircle(a.(*circle), b.(*circle))
		}
	}
	panic("unknown shapes")
}

func boxVSbox(a, b *box) *collision {
	relPos := b.pos.Sub(a.pos)
	overlapX := a.width.Add(b.width).Sub(relPos.X.Abs())
	if overlapX > 0 {
		overlapY := a.height.Add(b.height).Sub(relPos.Y.Abs())
		if overlapY > 0 {
			c := newCollision(a.body, b.body)
			if overlapX < overlapY {
				c.penetration = overlapX
				if relPos.X < 0 {
					c.normal = fixed.Vec2{-fixed.One, 0}
				} else {
					c.normal = fixed.Vec2{fixed.One, 0}
				}
			} else {
				c.penetration = overlapY
				if relPos.Y < 0 {
					c.normal = fixed.Vec2{0, -fixed.One}
				} else {
					c.normal = fixed.Vec2{0, fixed.One}
				}
			}
			return c
		}
	}
	return nil
}

func circleVScircle(a, b *circle) *collision {
	relPos := b.pos.Sub(a.pos)
	radii := a.radius.Add(b.radius)
	d := relPos.LengthSquared()
	if d < radii.Mul(radii) {
		d := d.Sqrt()
		c := newCollision(a.body, b.body)
		c.penetration = radii.Sub(d)
		if d != 0 {
			c.normal = relPos.Div(d)
		} else {
			c.normal = fixed.Vec2{fixed.One, 0}
		}
		return c
	}
	return nil
}

func boxVScircle(a *box, b *circle) *collision {
	relPos := b.pos.Sub(a.pos)
	closest := relPos
	xExtent := a.width
	yExtent := a.height
	closest.X = closest.X.Clamp(-xExtent, xExtent)
	closest.Y = closest.Y.Clamp(-yExtent, yExtent)
	inside := false
	xDist := fixed.Number(0)
	yDist := fixed.Number(0)
	if relPos == closest {
		inside = true
		xDist = xExtent.Sub(closest.X.Abs())
		yDist = yExtent.Sub(closest.Y.Abs())
		if xDist < yDist {
			if relPos.X > 0 {
				closest.X = xExtent
			} else {
				closest.X = -xExtent
			}
		} else {
			if relPos.Y > 0 {
				closest.Y = yExtent
			} else {
				closest.Y = -yExtent
			}
		}
	}
	normal := relPos.Sub(closest)
	d := normal.LengthSquared()
	r := b.radius
	if d > r.Mul(r) && !inside {
		return nil
	}
	c := newCollision(a.body, b.body)
	d = d.Sqrt()
	if d == 0 {
		if xDist == 0 {
			if relPos.X > 0 {
				c.normal = fixed.Vec2{fixed.One, 0}
			} else {
				c.normal = fixed.Vec2{-fixed.One, 0}
			}
		} else {
			if relPos.Y > 0 {
				c.normal = fixed.Vec2{0, fixed.One}
			} else {
				c.normal = fixed.Vec2{0, -fixed.One}
			}
		}
	} else {
		if inside {
			c.normal = normal.Div(-d)
		} else {
			c.normal = normal.Div(d)
		}
	}
	if inside {
		c.penetration = r + d
	} else {
		c.penetration = r - d
	}
	return c
}

func (c *collision) positionalCorrect() {
	a := c.a
	b := c.b
	s := fixed.Max(c.penetration.Sub(penetrationSlop), 0).Div(a.imass.Add(b.imass)).Mul(penetrationPercent)
	correction := c.normal.Mul(s)
	a.pos = a.pos.Sub(correction.Mul(a.imass))
	b.pos = b.pos.Add(correction.Mul(b.imass))
}

func (c *collision) resolve() {
	a := c.a
	b := c.b
	relVel := b.vel.Sub(a.vel)
	contactVel := relVel.Dot(c.normal)
	if contactVel > 0 {
		return
	}
	e := fixed.Min(a.rest, b.rest)
	j := -fixed.One.Add(e).Mul(contactVel)
	j = j.Div(a.imass.Add(b.imass))
	impulse := c.normal.Mul(j)
	a.vel = a.vel.Sub(impulse.Mul(a.imass))
	b.vel = b.vel.Add(impulse.Mul(b.imass))
}
