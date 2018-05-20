package physics

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

const iterations = 3

type World struct {
	counter    int
	bodies     []Body
	collisions []*collision
}

func (w *World) clearCollisions() {
	w.collisions = w.collisions[:0] // reuse underlying array
}
func (w *World) Step() {
	w.clearCollisions()
	for i := 0; i < len(w.bodies); i++ {
		for j := i + 1; j < len(w.bodies); j++ {
			a := w.bodies[i]
			b := w.bodies[j]
			c := checkCollision(a, b)
			if c != nil {
				w.collisions = append(w.collisions, c)
			}
		}
	}
	for _, b := range w.bodies {
		b.applyForce()
	}
	for i := 0; i < iterations; i++ {
		for _, c := range w.collisions {
			c.resolve()
		}
	}
	for _, b := range w.bodies {
		b.move()
	}
	for _, c := range w.collisions {
		c.positionalCorrect()
	}
}

func (w *World) AddCircle(mass, radius fixed.Number, pos fixed.Vec2) Body {
	b := &circle{
		radius: radius,
		body:   newBody(w.counter, mass, pos),
	}
	w.bodies = append(w.bodies, b)
	w.counter++
	return b
}

func (w *World) AddBox(mass, width, height fixed.Number, pos fixed.Vec2) Body {
	b := &box{
		width:  width,
		height: height,
		body:   newBody(w.counter, mass, pos),
	}
	w.bodies = append(w.bodies, b)
	w.counter++
	return b
}

func (w *World) RemoveBody(body Body) {
	for i, b := range w.bodies {
		if b.Id() == body.Id() {
			// https://github.com/golang/go/wiki/SliceTricks#delete-without-preserving-order
			w.bodies[i] = w.bodies[len(w.bodies)-1]
			w.bodies[len(w.bodies)-1] = nil
			w.bodies = w.bodies[:len(w.bodies)-1]
			return
		}
	}
}
