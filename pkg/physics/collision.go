package physics

import (
	"github.com/humblers/spaceknights/pkg/djb2"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type collision struct {
	a           *Body
	b           *Body
	normal      fixed.Vector
	penetration fixed.Scalar
}

func newCollision(a, b *Body) *collision {
	return &collision{
		a: a,
		b: b,
	}
}

func (c *collision) positionalCorrect(threshold, percent fixed.Scalar) {
	s := fixed.Max(c.penetration.Sub(threshold), 0)
	s = s.Div(c.a.imass.Add(c.b.imass)).Mul(percent)
	correction := c.normal.Mul(s)
	c.a.Pos = c.a.Pos.Sub(correction.Mul(c.a.imass))
	c.b.Pos = c.b.Pos.Add(correction.Mul(c.b.imass))
}

func (c *collision) resolve() {
	relVel := c.b.Vel.Sub(c.a.Vel)
	separation := relVel.Dot(c.normal)
	if separation > 0 {
		return
	}
	e := fixed.Min(c.a.rest, c.b.rest)
	j := (-fixed.One.Add(e)).Mul(separation)
	j = j.Div(c.a.imass.Add(c.b.imass))
	impulse := c.normal.Mul(j)
	c.a.Vel = c.a.Vel.Sub(impulse.Mul(c.a.imass))
	c.b.Vel = c.b.Vel.Add(impulse.Mul(c.b.imass))
}

func (c *collision) digest(opt ...uint32) uint32 {
	h := djb2.Hash(c.penetration, opt...)
	h = djb2.Hash(c.normal, h)
	h = c.a.digest(h)
	return c.b.digest(h)
}
