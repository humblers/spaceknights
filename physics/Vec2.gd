extends Node

func Create(x, y):
	return {
		"X": x,
		"Y": y,
	}

func Equal(a, b):
	return a.X == b.X and a.Y == b.Y

func Add(a, b):
	return Create(Q.Add(a.X, b.X), Q.Add(a.Y, b.Y))

func AddInplace(a, b):
	a.X = Q.Add(a.X, b.X)
	a.Y = Q.Add(a.Y, b.Y)

func Sub(a, b):
	return Create(Q.Sub(a.X, b.X), Q.Sub(a.Y, b.Y))

func SubInplace(a, b):
	a.X = Q.Sub(a.X, b.X)
	a.Y = Q.Sub(a.Y, b.Y)

func Mul(v, s):
	return Create(Q.Mul(v.X, s), Q.Mul(v.Y, s))

func MulInplace(v, s):
	v.X = Q.Mul(v.X, s)
	v.Y = Q.Mul(v.Y, s)

func Div(v, s):
	return Create(Q.Div(v.X, s), Q.Div(v.Y, s))

func DivInplace(v, s):
	v.X = Q.Div(v.X, s)
	v.Y = Q.Div(v.Y, s)

func Dot(a, b):
	return Q.Add(Q.Mul(a.X, b.X), Q.Mul(a.Y, b.Y))

func LengthSquared(v):
	return Q.Add(Q.Pow2(v.X), Q.Pow2(v.Y))

func Length(v):
	return Q.Sqrt(LengthSquared(v))
