extends Node

const ZERO = {"X": 0, "Y": 0}

static func Create(x, y):
	return {
		"X": x,
		"Y": y,
	}

static func Equal(a, b):
	return a.X == b.X and a.Y == b.Y

static func Add(a, b):
	return Create(Q.Add(a.X, b.X), Q.Add(a.Y, b.Y))

static func AddInplace(a, b):
	a.X = Q.Add(a.X, b.X)
	a.Y = Q.Add(a.Y, b.Y)

static func Sub(a, b):
	return Create(Q.Sub(a.X, b.X), Q.Sub(a.Y, b.Y))

static func SubInplace(a, b):
	a.X = Q.Sub(a.X, b.X)
	a.Y = Q.Sub(a.Y, b.Y)

static func Mul(v, s):
	return Create(Q.Mul(v.X, s), Q.Mul(v.Y, s))

static func MulInplace(v, s):
	v.X = Q.Mul(v.X, s)
	v.Y = Q.Mul(v.Y, s)

static func Div(v, s):
	return Create(Q.Div(v.X, s), Q.Div(v.Y, s))

static func DivInplace(v, s):
	v.X = Q.Div(v.X, s)
	v.Y = Q.Div(v.Y, s)

static func Dot(a, b):
	return Q.Add(Q.Mul(a.X, b.X), Q.Mul(a.Y, b.Y))

static func Cross(a, b):
	return Q.Sub(Q.Mul(a.X, b.Y), Q.Mul(a.Y, b.X))

static func LengthSquared(v):
	return Q.Add(Q.Pow2(v.X), Q.Pow2(v.Y))

static func Length(v):
	return Q.Sqrt(LengthSquared(v))

static func Normalize(v):
	return Div(v, Length(v))

static func Truncate(v, s):
	if LengthSquared(v) > Q.Pow2(s):
		return Mul(Normalize(v), s)
	return v
