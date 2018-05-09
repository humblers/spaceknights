package physics

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

const restitution = fixed.Tenth * 5 // 0.5

type Body interface {
	Id() int
	//	Velocity() fixed.Vec2
	//	Position() fixed.Vec2
	ApplyForce()
	Move()
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

func (b *body) ApplyForce() {
	if b.mass == 0 {
		return
	}
	accel := b.force.Mul(b.imass)
	b.vel = b.vel.Add(accel.Mul(dt))
	b.force.X = 0
	b.force.Y = 0
}

func (b *body) Move() {
	if b.mass == 0 {
		return
	}
	b.pos = b.pos.Add(b.vel.Mul(dt))
}
