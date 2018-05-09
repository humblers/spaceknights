package fixed

// Vec2 represents a fixed point 2d vector
type Vec2 struct {
	X, Y Number
}

func (a Vec2) Add(b Vec2) Vec2 {
	return Vec2{
		X: a.X.Add(b.X),
		Y: a.Y.Add(b.Y),
	}
}

func (a Vec2) Sub(b Vec2) Vec2 {
	return Vec2{
		X: a.X.Sub(b.X),
		Y: a.Y.Sub(b.Y),
	}
}

func (a Vec2) Mul(s Number) Vec2 {
	return Vec2{
		X: a.X.Mul(s),
		Y: a.Y.Mul(s),
	}
}

func (a Vec2) Div(s Number) Vec2 {
	return Vec2{
		X: a.X.Div(s),
		Y: a.Y.Div(s),
	}
}

func (a Vec2) Dot(b Vec2) Number {
	return a.X.Mul(b.X).Add(a.Y.Mul(b.Y))
}

func (a Vec2) Cross(b Vec2) Number {
	return a.X.Mul(b.Y).Sub(a.Y.Mul(b.X))
}

func (a Vec2) LengthSquared() Number {
	return a.X.Mul(a.X).Add(a.Y.Mul(a.Y))
}

func (a Vec2) Length() Number {
	return a.LengthSquared().Sqrt()
}

func (a Vec2) Normalized() Vec2 {
	return a.Div(a.Length())
}

func (a Vec2) Truncated(s Number) Vec2 {
	l := a.LengthSquared()
	if l > s.Mul(s) {
		l = l.Sqrt()
		return a.Mul(s.Div(l))
	}
	return a
}
