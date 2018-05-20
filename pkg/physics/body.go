package physics

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

var (
	restitution = fixed.One.Div(fixed.Two)         // 0.5
	dt          = fixed.One.Div(fixed.FromInt(60)) // 1/60
)

type Body interface {
	Id() int
	//	Velocity() fixed.Vec2
	//	Position() fixed.Vec2
	applyForce()
	move()
}

type body struct {
	id    int
	mass  fixed.Number
	imass fixed.Number
	rest  fixed.Number // restitution
	vel   fixed.Vec2
	pos   fixed.Vec2
	force fixed.Vec2
}

type box struct {
	width, height fixed.Number
	*body
}

type circle struct {
	radius fixed.Number
	*body
}

func (b *body) Id() int {
	return b.id
}

/*
func (b *body) Velocity() fixed.Vec2 {
	return b.vel
}

func (b *body) Position() fixed.Vec2 {
	return b.pos
}
*/

func newBody(id int, mass fixed.Number, pos fixed.Vec2) *body {
	var imass fixed.Number
	if mass == 0 {
		imass = 0
	} else {
		imass = fixed.One.Div(mass)
	}
	return &body{
		id:    id,
		mass:  mass,
		imass: imass,
		rest:  restitution,
		pos:   pos,
	}
}

func (b *body) applyForce() {
	if b.mass == 0 {
		return
	}
	accel := b.force.Mul(b.imass)
	b.vel = b.vel.Add(accel.Mul(dt))
	b.force.X = 0
	b.force.Y = 0
}

func (b *body) move() {
	if b.mass == 0 {
		return
	}
	b.pos = b.pos.Add(b.vel.Mul(dt))
}
