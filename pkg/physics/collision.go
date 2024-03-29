package physics

import (
	"github.com/humblers/spaceknights/pkg/djb2"
	"github.com/humblers/spaceknights/pkg/fixed"
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
	c.a.colliding = true
	c.b.colliding = true
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

func (c *collision) State() map[string]interface{} {
	return map[string]interface{}{
		"a":           c.a.id,
		"b":           c.b.id,
		"normal":      c.normal,
		"penetration": c.penetration,
	}
}

func (c *collision) Hash() uint32 {
	return djb2.Combine(
		djb2.HashInt(c.a.id),
		djb2.HashInt(c.b.id),
		c.normal.Hash(),
		c.penetration.Hash(),
	)
}
