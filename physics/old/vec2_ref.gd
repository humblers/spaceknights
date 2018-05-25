extends Reference

var X = 0
var Y = 0

func _init(x, y):
	X = x
	Y = y

func ToString():
	return "{X:%s, Y:%s}" % [X, Y]

func Equal(v):
	return X == v.X and Y == v.Y

func Add(v):
	return get_script().new(number.Add(X, v.X), number.Add(Y,v.Y))

func Sub(v):
	return get_script().new(number.Sub(X, v.X), number.Sub(Y,v.Y))

func Mul(s):
	return get_script().new(number.Mul(X, s), number.Mul(Y, s))

func Div(s):
	return get_script().new(number.Div(X, s), number.Div(Y, s))

func Dot(v):
	return number.Add(number.Mul(X, v.X), number.Mul(Y, v.Y))

func Cross(v):
	return number.Sub(number.Mul(X, v.Y), number.Mul(Y, v.X))

func LengthSquared():
	return number.Add(number.Mul(X, X), number.Mul(Y, Y))

func Length():
	return number.Sqrt(LengthSquared())

func Normalized():
	return Div(Length())

func Truncated(s):
	var l = LengthSquared()
	if l > number.Mul(s, s):
		l = number.Sqrt(l)
		return Mul(number.Div(s, l))
	return self
