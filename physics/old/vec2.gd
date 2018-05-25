extends Node

static func Dot(Ax, Ay, Bx, By):
	return number.Add(number.Mul(Ax, Bx), number.Mul(Ay, By))

static func Cross(Ax, Ay, Bx, By):
	return number.Sub(number.Mul(Ax, By), number.Mul(Ay, Bx))

static func LengthSquared(x, y):
	return number.Add(number.Mul(x, x), number.Mul(y, y))

static func Length(x, y):
	return number.Sqrt(LengthSquared(x, y))
