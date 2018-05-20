extends Node

const ZERO = {"X": 0, "Y": 0}

static func New(x, y):
	return {
		"X": x,
		"Y": y,
	}

static func Equal(a, b):
	return a.X == b.X and a.Y == b.Y

static func Add(a, b):
	return New(number.Add(a.X, b.X), number.Add(a.Y, b.Y))

static func Sub(a, b):
	return New(number.Sub(a.X, b.X), number.Sub(a.Y, b.Y))

static func Mul(v, s):
	return New(number.Mul(v.X, s), number.Mul(v.Y, s))

static func Div(v, s):
	return New(number.Div(v.X, s), number.Div(v.Y, s))

static func Dot(a, b):
	return number.Add(number.Mul(a.X, b.X), number.Mul(a.Y, b.Y))

static func Cross(a, b):
	return number.Sub(number.Mul(a.X, b.Y), number.Mul(a.Y, b.X))

static func LengthSquared(v):
	return number.Add(number.Mul(v.X, v.X), number.Mul(v.Y, v.Y))

static func Length(v):
	return number.Sqrt(LengthSquared(v))

static func Normalized(v):
	return Div(v, Length(v))

static func Truncated(v, s):
	var l = LengthSquared(v)
	if l > number.Mul(s, s):
		l = number.Sqrt(l)
		return Mul(v, number.Div(s, l))
	return v