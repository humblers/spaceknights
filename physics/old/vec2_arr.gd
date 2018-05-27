extends Node

const ZERO = [0, 0]

static func New(x, y):
	return [x, y]

static func Equal(a, b):
	return a[0] == b[0] and a[1] == b[1]

static func Add(a, b):
	return New(number.Add(a[0], b[0]), number.Add(a[1], b[1]))

static func Sub(a, b):
	return New(number.Sub(a[0], b[0]), number.Sub(a[1], b[1]))

static func Mul(v, s):
	return New(number.Mul(v[0], s), number.Mul(v[1], s))

static func Div(v, s):
	return New(number.Div(v[0], s), number.Div(v[1], s))

static func Dot(a, b):
	return number.Add(number.Mul(a[0], b[0]), number.Mul(a[1], b[1]))

static func Cross(a, b):
	return number.Sub(number.Mul(a[0], b[1]), number.Mul(a[1], b[0]))

static func LengthSquared(v):
	return number.Add(number.Mul(v[0], v[0]), number.Mul(v[1], v[1]))

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