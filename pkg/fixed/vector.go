package fixed

import "github.com/humblers/spaceknights/pkg/djb2"

// Vector represents a fixed point 2d vector
type Vector struct {
	X, Y Scalar
}

func (v Vector) Hash() uint32 {
	return djb2.Combine(v.X.Hash(), v.Y.Hash())
}

func (a Vector) Add(b Vector) Vector {
	return Vector{
		X: a.X.Add(b.X),
		Y: a.Y.Add(b.Y),
	}
}

func (a Vector) Sub(b Vector) Vector {
	return Vector{
		X: a.X.Sub(b.X),
		Y: a.Y.Sub(b.Y),
	}
}

func (a Vector) Mul(s Scalar) Vector {
	return Vector{
		X: a.X.Mul(s),
		Y: a.Y.Mul(s),
	}
}

func (a Vector) Div(s Scalar) Vector {
	return Vector{
		X: a.X.Div(s),
		Y: a.Y.Div(s),
	}
}

func (a Vector) Dot(b Vector) Scalar {
	return a.X.Mul(b.X).Add(a.Y.Mul(b.Y))
}

func (a Vector) Cross(b Vector) Scalar {
	return a.X.Mul(b.Y).Sub(a.Y.Mul(b.X))
}

func (a Vector) LengthSquared() Scalar {
	return a.X.Mul(a.X).Add(a.Y.Mul(a.Y))
}

func (a Vector) Length() Scalar {
	return a.LengthSquared().Sqrt()
}

func (a Vector) Normalized() Vector {
	return a.Div(a.Length())
}

func (a Vector) Truncated(s Scalar) Vector {
	l := a.LengthSquared()
	if l > s.Mul(s) {
		l = l.Sqrt()
		return a.Mul(s.Div(l))
	}
	return a
}
