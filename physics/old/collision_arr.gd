extends Reference

const vec2 = preload("res://fixed/vec2_arr.gd")

var penetrationPercent = number.Div(number.ONE, number.FromInt(5))		# 0.2
var penetrationSlop = number.Div(number.ONE, number.FromInt(100))		# 0.01

var a
var b
var normal = vec2.New(0, 0)
var penetration = 0

func _init(a, b):
	self.a = a
	self.b = b

func positionalCorrect():
	var s = number.Mul(number.Div(number.Max(number.Sub(penetration, penetrationSlop), 0), number.Add(a.imass, b.imass)), penetrationPercent)
	var correction = vec2.Mul(normal, s)
	a.pos = vec2.Sub(a.pos, vec2.Mul(correction, a.imass))
	b.pos = vec2.Add(b.pos, vec2.Mul(correction, b.imass))

func resolve():
	var relVel = vec2.Sub(b.vel, a.vel)
	var contactVel = vec2.Dot(relVel, normal)
	if contactVel > 0:
		return
	var e = number.Min(a.rest, b.rest)
	var j = number.Mul(-number.Add(number.ONE, e), contactVel)
	j = number.Div(j, number.Add(a.imass, b.imass))
	var impulse = vec2.Mul(normal, j)
	a.vel = vec2.Sub(a.vel, vec2.Mul(impulse, a.imass))
	b.vel = vec2.Add(b.vel, vec2.Mul(impulse, b.imass))
