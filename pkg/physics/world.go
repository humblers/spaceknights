package physics

import (
	"github.com/humblers/spaceknights/pkg/djb2"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type World interface {
	Dt() fixed.Scalar
	FromPixel(v int) fixed.Scalar
	ToPixel(v fixed.Scalar) int
	Step()
	AddBox(mass, width, height fixed.Scalar, pos fixed.Vector) Body
	AddCircle(mass, radius fixed.Scalar, pos fixed.Vector) Body
	RemoveBody(b Body)
	Hash() uint32
	State() map[string]interface{}
}

type world struct {
	counter    int
	bodies     []*body
	collisions []*collision

	scale               fixed.Scalar
	dt                  fixed.Scalar
	iterations          int
	gravity             fixed.Vector
	restitution         fixed.Scalar
	correctionPercent   fixed.Scalar
	correctionThreshold fixed.Scalar
}

func NewWorld(params map[string]fixed.Scalar) World {
	w := &world{
		scale:               fixed.One,
		dt:                  fixed.One.Div(fixed.FromInt(10)),
		iterations:          3,
		gravity:             fixed.Vector{0, fixed.FromInt(1000)},
		restitution:         fixed.One.Div(fixed.Two),
		correctionPercent:   fixed.Two.Div(fixed.FromInt(5)),
		correctionThreshold: fixed.One.Div(fixed.FromInt(100)),
	}
	for k, v := range params {
		switch k {
		case "scale":
			w.scale = v
		case "dt":
			w.dt = v
		case "gravity_x":
			w.gravity.X = v
		case "gravity_y":
			w.gravity.Y = v
		case "restitution":
			w.restitution = v
		}
	}
	return w
}

func (w *world) Dt() fixed.Scalar {
	return w.dt
}

func (w *world) FromPixel(v int) fixed.Scalar {
	return fixed.FromInt(v).Mul(w.scale)
}

func (w *world) ToPixel(v fixed.Scalar) int {
	return v.Div(w.scale).ToInt()
}

func (w *world) clearCollisions() {
	w.collisions = w.collisions[:0] // reuse underlying array
}
func (w *world) Step() {
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
		b.colliding = false
		b.applyForce(w.gravity, w.dt)
	}
	/*
		for i := 0; i < w.iterations; i++ {
			for _, c := range w.collisions {
				c.resolve()
			}
		}
	*/
	for _, b := range w.bodies {
		b.move(w.dt)
	}
	for _, c := range w.collisions {
		c.positionalCorrect(w.correctionThreshold, w.correctionPercent)
	}
}

func (w *world) AddBox(mass, width, height fixed.Scalar, pos fixed.Vector) Body {
	b := w.addBody(mass, pos)
	b.setAsBox(width, height)
	return b
}

func (w *world) AddCircle(mass, radius fixed.Scalar, pos fixed.Vector) Body {
	b := w.addBody(mass, pos)
	b.setAsCircle(radius)
	return b
}

func (w *world) addBody(mass fixed.Scalar, pos fixed.Vector) *body {
	b := newBody(w.counter, mass, w.restitution, pos)
	w.bodies = append(w.bodies, b)
	w.counter++
	return b
}

func (w *world) RemoveBody(b Body) {
	bodies := w.bodies
	for i := 0; i < len(bodies); i++ {
		if bodies[i].id == b.Id() {
			// https://github.com/golang/go/wiki/SliceTricks#delete-without-preserving-order
			bodies[i] = bodies[len(bodies)-1]
			bodies[len(bodies)-1] = nil
			w.bodies = bodies[:len(bodies)-1]
			return
		}
	}
}

func (w *world) State() map[string]interface{} {
	state := map[string]interface{}{
		"counter":             w.counter,
		"iterations":          w.iterations,
		"scale":               w.scale,
		"dt":                  w.dt,
		"gravity":             w.gravity,
		"restitution":         w.restitution,
		"correctionPercent":   w.correctionPercent,
		"correctionThreshold": w.correctionThreshold,
	}
	collisions := []interface{}{}
	for _, c := range w.collisions {
		collisions = append(collisions, c.State())
	}
	state["collisions"] = collisions
	return state
}

func (w *world) Hash() uint32 {
	hashes := []uint32{
		djb2.HashInt(w.counter),
		djb2.HashInt(w.iterations),
		w.scale.Hash(),
		w.dt.Hash(),
		w.gravity.Hash(),
		w.restitution.Hash(),
		w.correctionPercent.Hash(),
		w.correctionThreshold.Hash(),
	}
	for _, c := range w.collisions {
		hashes = append(hashes, c.Hash())
	}
	return djb2.Combine(hashes...)
}

func checkCollision(a, b *body) *collision {
	if a.no_physics || b.no_physics {
		return nil
	}
	if a.layer != b.layer {
		return nil
	}
	if a.imass == 0 && b.imass == 0 {
		return nil
	}
	switch a.shape {
	case box:
		switch b.shape {
		case box:
			return boxVSbox(a, b)
		case circle:
			return boxVScircle(a, b)
		}
	case circle:
		switch b.shape {
		case box:
			return boxVScircle(b, a)
		case circle:
			return circleVScircle(a, b)
		}
	}
	panic("unknown shapes")
}

func boxVSbox(a, b *body) *collision {
	relPos := b.pos.Sub(a.pos)
	overlapX := a.width.Add(b.width).Sub(relPos.X.Abs())
	if overlapX > 0 {
		overlapY := a.height.Add(b.height).Sub(relPos.Y.Abs())
		if overlapY > 0 {
			c := newCollision(a, b)
			if overlapX < overlapY {
				c.penetration = overlapX
				if relPos.X < 0 {
					c.normal = fixed.Vector{-fixed.One, 0}
				} else {
					c.normal = fixed.Vector{fixed.One, 0}
				}
			} else {
				c.penetration = overlapY
				if relPos.Y < 0 {
					c.normal = fixed.Vector{0, -fixed.One}
				} else {
					c.normal = fixed.Vector{0, fixed.One}
				}
			}
			return c
		}
	}
	return nil
}

func circleVScircle(a, b *body) *collision {
	relPos := b.pos.Sub(a.pos)
	radii := a.radius.Add(b.radius)
	d := relPos.LengthSquared()
	if d < radii.Mul(radii) {
		d := d.Sqrt()
		c := newCollision(a, b)
		c.penetration = radii.Sub(d)
		if d != 0 {
			c.normal = relPos.Div(d)
		} else {
			c.normal = fixed.Vector{fixed.One, 0}
		}
		return c
	}
	return nil
}

func boxVScircle(a, b *body) *collision {
	relPos := b.pos.Sub(a.pos)
	closest := relPos
	xExtent := a.width
	yExtent := a.height
	closest.X = closest.X.Clamp(-xExtent, xExtent)
	closest.Y = closest.Y.Clamp(-yExtent, yExtent)
	inside := false
	if relPos == closest {
		inside = true
		xDist := xExtent.Sub(closest.X.Abs())
		yDist := yExtent.Sub(closest.Y.Abs())
		if xDist < yDist {
			if relPos.X > 0 {
				closest.X = xExtent
			} else {
				closest.X = -xExtent
			}
		} else {
			if relPos.Y > 0 {
				closest.Y = yExtent
			} else {
				closest.Y = -yExtent
			}
		}
	}
	normal := relPos.Sub(closest)
	d := normal.LengthSquared()
	r := b.radius
	if d > r.Mul(r) && !inside {
		return nil
	}
	c := newCollision(a, b)
	d = d.Sqrt()
	if inside {
		c.penetration = r + d
	} else {
		c.penetration = r - d
	}
	if d != 0 {
		if inside {
			c.normal = normal.Div(-d)
		} else {
			c.normal = normal.Div(d)
		}
	} else {
		if closest.X == xExtent {
			c.normal = fixed.Vector{fixed.One, 0}
		} else if closest.X == -xExtent {
			c.normal = fixed.Vector{-fixed.One, 0}
		} else if closest.Y == yExtent {
			c.normal = fixed.Vector{0, fixed.One}
		} else if closest.Y == -yExtent {
			c.normal = fixed.Vector{0, -fixed.One}
		} else {
			panic("unknown box vs circle collision, should not be here")
		}
	}
	return c
}
