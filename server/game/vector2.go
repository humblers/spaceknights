package main

import "math"

type Vector2 struct {
	X, Y float64
}

func (v Vector2) FlipY() Vector2 {
	return Vector2{
		X: v.X,
		Y: -v.Y,
	}
}

func (v Vector2) Clamp(minX, maxX, minY, maxY float64) Vector2 {
	return Vector2{
		X: math.Min(math.Max(minX, v.X), maxX),
		Y: math.Min(math.Max(minY, v.Y), maxY),
	}
}

func (a Vector2) Plus(b Vector2) Vector2 {
	return Vector2{
		X: a.X + b.X,
		Y: a.Y + b.Y,
	}
}

func (a Vector2) Minus(b Vector2) Vector2 {
	return Vector2{
		X: a.X - b.X,
		Y: a.Y - b.Y,
	}
}

func (v Vector2) Multiply(c float64) Vector2 {
	return Vector2{
		X: v.X * c,
		Y: v.Y * c,
	}
}

func (v Vector2) Divide(c float64) Vector2 {
	return Vector2{
		X: v.X / c,
		Y: v.Y / c,
	}
}

func (v Vector2) Rotate(c float64) Vector2 {
	return Vector2{
		X: v.X*math.Cos(c) - v.Y*math.Sin(c),
		Y: v.X*math.Sin(c) + v.Y*math.Cos(c),
	}
}

func (v Vector2) Truncate(c float64) Vector2 {
	if v.Length() > c {
		return v.Normalize().Multiply(c)
	}
	return v
}

func (v Vector2) Length() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v Vector2) Normalize() Vector2 {
	l := v.Length()
	if l == 0 {
		//panic("cannot normalize zero vector")
		return Vector2{0, 0}
	}
	return Vector2{
		X: v.X / l,
		Y: v.Y / l,
	}
}

func (a Vector2) Cross(b Vector2) float64 {
	return a.X*b.Y - a.Y*b.X
}

func (a Vector2) Dot(b Vector2) float64 {
	return a.X*b.X + a.Y*b.Y
}

func (position Vector2) ToLocalCoordinate(unit *Unit) Vector2 {
	v := unit.Velocity.Normalize()
	u := Vector2{v.Y, -v.X}
	translated := position.Minus(unit.Position)
	x := u.Dot(translated)
	y := v.Dot(translated)
	return Vector2{x, y}
}
