package physics

import (
	"git.humbler.games/spaceknights/spaceknights/pkg/fixed"
	"git.humbler.games/spaceknights/spaceknights/pkg/hash"
)

type collision struct {
	a           *body
	b           *body
	normal      fixed.Vector
	penetration fixed.Scalar
}

func newCollision(a, b *body) *collision {
	return &collision{
		a: a,
		b: b,
	}
}

func (c *collision) positionalCorrect(threshold, percent fixed.Scalar) {
	s := fixed.Max(c.penetration.Sub(threshold), 0)
	s = s.Div(c.a.imass.Add(c.b.imass)).Mul(percent)
	correction := c.normal.Mul(s)
	c.a.pos = c.a.pos.Sub(correction.Mul(c.a.imass))
	c.b.pos = c.b.pos.Add(correction.Mul(c.b.imass))
}

func (c *collision) resolve() {
	relVel := c.b.vel.Sub(c.a.vel)
	separation := relVel.Dot(c.normal)
	if separation > 0 {
		return
	}
	e := fixed.Min(c.a.rest, c.b.rest)
	j := (-fixed.One.Add(e)).Mul(separation)
	j = j.Div(c.a.imass.Add(c.b.imass))
	impulse := c.normal.Mul(j)
	c.a.vel = c.a.vel.Sub(impulse.Mul(c.a.imass))
	c.b.vel = c.b.vel.Add(impulse.Mul(c.b.imass))
}

func (c *collision) digest(opt ...uint32) uint32 {
	h := hash.HashDJB2(c.penetration, opt...)
	h = hash.HashDJB2(c.normal, h)
	h = c.a.digest(h)
	return c.b.digest(h)
}
