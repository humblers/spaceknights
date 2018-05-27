extends Node

static func Dot(Ax, Ay, Bx, By):
	return scalar.Add(scalar.Mul(Ax, Bx), scalar.Mul(Ay, By))

static func Cross(Ax, Ay, Bx, By):
	return scalar.Sub(scalar.Mul(Ax, By), scalar.Mul(Ay, Bx))

static func LengthSquared(x, y):
	return scalar.Add(scalar.Mul(x, x), scalar.Mul(y, y))

static func Length(x, y):
	return scalar.Sqrt(LengthSquared(x, y))
