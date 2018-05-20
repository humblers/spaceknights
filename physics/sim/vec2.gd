extends Node

static func Dot(Ax, Ay, Bx, By):
	return Q.Add(Q.Mul(Ax, Bx), Q.Mul(Ay, By))

static func Cross(Ax, Ay, Bx, By):
	return Q.Sub(Q.Mul(Ax, By), Q.Mul(Ay, Bx))

static func LengthSquared(x, y):
	return Q.Add(Q.Mul(x, x), Q.Mul(y, y))

static func Length(x, y):
	return Q.Sqrt(LengthSquared(x, y))
