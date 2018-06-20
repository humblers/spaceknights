package physics

import (
	"git.humbler.games/spaceknights/spaceknights/pkg/djb2"
	"git.humbler.games/spaceknights/spaceknights/pkg/fixed"
)

type Body struct {
	id    int
	mass  fixed.Scalar
	imass fixed.Scalar
	rest  fixed.Scalar // restitution
	Pos   fixed.Vector
	Vel   fixed.Vector
	force fixed.Vector

	shape  shape
	Radius fixed.Scalar
	width  fixed.Scalar
	height fixed.Scalar
}

type shape string

const (
	box    shape = "box"
	circle shape = "circle"
)

func newBody(id int, mass, rest fixed.Scalar, pos fixed.Vector) *Body {
	var imass fixed.Scalar
	if mass == 0 {
		imass = 0
	} else {
		imass = fixed.One.Div(mass)
	}
	return &Body{
		id:    id,
		mass:  mass,
		imass: imass,
		rest:  rest,
		Pos:   pos,
	}
}

func (b *Body) setAsBox(width, height fixed.Scalar) {
	b.shape = box
	b.width = width
	b.height = height
}

func (b *Body) setAsCircle(radius fixed.Scalar) {
	b.shape = circle
	b.Radius = radius
}

func (b *Body) applyForce(gravity fixed.Vector, dt fixed.Scalar) {
	if b.mass == 0 {
		return
	}
	accel := b.force.Mul(b.imass).Add(gravity)
	b.Vel = b.Vel.Add(accel.Mul(dt))
	b.force.X = 0
	b.force.Y = 0
}

func (b *Body) move(dt fixed.Scalar) {
	if b.mass == 0 {
		return
	}
	b.Pos = b.Pos.Add(b.Vel.Mul(dt))
}

func (b *Body) digest(opt ...uint32) uint32 {
	h := djb2.Hash(uint32(b.id), opt...)
	for _, e := range []interface{}{b.mass, b.imass, b.rest, b.Pos, b.Vel, b.force, []byte(b.shape), b.Radius, b.width, b.height} {
		h = djb2.Hash(e, h)
	}
	return h
}
