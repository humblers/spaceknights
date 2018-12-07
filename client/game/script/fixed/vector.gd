extends Node

static func Dot(Ax, Ay, Bx, By):
	return scalar.Add(scalar.Mul(Ax, Bx), scalar.Mul(Ay, By))

static func Cross(Ax, Ay, Bx, By):
	return scalar.Sub(scalar.Mul(Ax, By), scalar.Mul(Ay, Bx))

static func LengthSquared(x, y):
	return scalar.Add(scalar.Mul(x, x), scalar.Mul(y, y))

static func Length(x, y):
	return scalar.Sqrt(LengthSquared(x, y))

static func Normalized(x, y):
	var l = Length(x, y)
	return [scalar.Div(x, l), scalar.Div(y, l)]

static func Truncated(x, y, s):
	var l = LengthSquared(x, y)
	if l > scalar.Mul(s, s):
		l = scalar.Sqrt(l)
		var d = scalar.Div(s, l)
		return [scalar.Mul(x, d), scalar.Mul(y, d)]
	return [x, y]
