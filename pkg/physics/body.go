package physics

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

type body struct {
	id    int
	mass  fixed.Scalar
	imass fixed.Scalar
	rest  fixed.Scalar // restitution
	pos   fixed.Vector
	vel   fixed.Vector
	force fixed.Vector

	shape  shape
	radius fixed.Scalar
	width  fixed.Scalar
	height fixed.Scalar
}

type shape string

const (
	box    shape = "box"
	circle shape = "circle"
)

func newBody(id int, mass, rest fixed.Scalar, pos fixed.Vector) *body {
	var imass fixed.Scalar
	if mass == 0 {
		imass = 0
	} else {
		imass = fixed.One.Div(mass)
	}
	return &body{
		id:    id,
		mass:  mass,
		imass: imass,
		rest:  rest,
		pos:   pos,
	}
}

func (b *body) setAsBox(width, height fixed.Scalar) {
	b.shape = box
	b.width = width
	b.height = height
}

func (b *body) setAsCircle(radius fixed.Scalar) {
	b.shape = circle
	b.radius = radius
}

func (b *body) applyForce(gravity fixed.Vector, dt fixed.Scalar) {
	if b.mass == 0 {
		return
	}
	accel := b.force.Mul(b.imass).Add(gravity)
	b.vel = b.vel.Add(accel.Mul(dt))
	b.force.X = 0
	b.force.Y = 0
}

func (b *body) move(dt fixed.Scalar) {
	if b.mass == 0 {
		return
	}
	b.pos = b.pos.Add(b.vel.Mul(dt))
}
