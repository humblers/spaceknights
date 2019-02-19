package physics

import (
	"github.com/humblers/spaceknights/pkg/djb2"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type Body interface {
	Id() int
	Position() fixed.Vector
	SetPosition(p fixed.Vector)
	Velocity() fixed.Vector
	SetVelocity(v fixed.Vector)
	Radius() fixed.Scalar
	Simulate(on bool)
	Layer() string
	SetLayer(l string)
	AddForce(f fixed.Vector)
	Colliding() bool
	Hash() uint32
	State() map[string]interface{}
}

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

	no_physics bool
	layer      string
	colliding  bool
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

func (b *body) Id() int {
	return b.id
}

func (b *body) Position() fixed.Vector {
	return b.pos
}

func (b *body) SetPosition(p fixed.Vector) {
	b.pos = p
}

func (b *body) Colliding() bool {
	return b.colliding
}

func (b *body) Velocity() fixed.Vector {
	return b.vel
}

func (b *body) SetVelocity(v fixed.Vector) {
	b.vel = v
}

func (b *body) Radius() fixed.Scalar {
	return b.radius
}

func (b *body) Simulate(on bool) {
	b.no_physics = !on
}

func (b *body) Layer() string {
	return b.layer
}

func (b *body) SetLayer(l string) {
	b.layer = l
}

func (b *body) AddForce(f fixed.Vector) {
	b.force = b.force.Add(f)
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
	accel := b.force.Mul(b.imass).Add(gravity)
	b.vel = b.vel.Add(accel.Mul(dt))
	b.force.X = 0
	b.force.Y = 0
}

func (b *body) move(dt fixed.Scalar) {
	if b.mass == 0 || b.no_physics {
		return
	}
	b.pos = b.pos.Add(b.vel.Mul(dt))
}

func (b *body) Hash() uint32 {
	return djb2.Combine(
		djb2.HashInt(b.id),
		b.mass.Hash(),
		b.imass.Hash(),
		b.rest.Hash(),
		b.pos.Hash(),
		b.vel.Hash(),
		b.force.Hash(),
		djb2.HashString(string(b.shape)),
		b.radius.Hash(),
		b.width.Hash(),
		b.height.Hash(),
		djb2.HashBool(b.no_physics),
		djb2.HashString(b.layer),
		djb2.HashBool(b.colliding),
	)
}

func (b *body) State() map[string]interface{} {
	return map[string]interface{}{
		"id":         b.id,
		"mass":       b.mass,
		"imass":      b.imass,
		"rest":       b.rest,
		"pos":        b.pos,
		"vel":        b.vel,
		"force":      b.force,
		"shape":      b.shape,
		"radius":     b.radius,
		"width":      b.width,
		"height":     b.height,
		"no_physics": b.no_physics,
		"layer":      b.layer,
		"colliding":  b.colliding,
	}
}
