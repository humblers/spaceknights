package physics

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

const iterations = 3

var dt = fixed.One.Div(fixed.FromInt(60)) // 1/60

type World struct {
	counter    int
	bodies     map[int]Body
	collisions []*collision
}

func NewWorld() *World {
	return &World{
		bodies: make(map[int]Body),
	}
}

func (w *World) Step() {
	w.collisions = w.collisions[:0] // reuse underlying array
	for _, a := range w.bodies {
		for _, b := range w.bodies {
			if a.Id() < b.Id() {
				c := checkCollision(a, b)
				if c.penetration > 0 {
					w.collisions = append(w.collisions, c)
				}
			}
		}
	}
	for _, b := range w.bodies {
		b.ApplyForce()
	}
	for i := 0; i < iterations; i++ {
		for _, c := range w.collisions {
			c.resolve()
		}
	}
	for _, b := range w.bodies {
		b.Move()
	}
	for _, c := range w.collisions {
		c.positionalCorrect()
	}
}

func (w *World) CreateCircle(mass, radius fixed.Number, pos fixed.Vec2) Body {
	c := &circle{
		radius: radius,
		body:   newBody(w.counter, mass, pos),
	}
	w.bodies[w.counter] = c
	w.counter++
	return c
}

func (w *World) CreateBox(mass, width, height fixed.Number, pos fixed.Vec2) Body {
	b := &box{
		width:  width,
		height: height,
		body:   newBody(w.counter, mass, pos),
	}
	w.bodies[w.counter] = b
	w.counter++
	return b
}

func (w *World) RemoveBody(b Body) {
	delete(w.bodies, b.Id())
}
