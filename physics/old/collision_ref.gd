extends Reference

const vec2 = preload("res://fixed/vec2_ref.gd")

var penetrationPercent = number.Div(number.ONE, number.FromInt(5))		# 0.2
var penetrationSlop = number.Div(number.ONE, number.FromInt(100))		# 0.01

var a
var b
var normal = vec2.new(0, 0)
var penetration = 0

func _init(a, b):
	self.a = a
	self.b = b

func positionalCorrect():
	var s = number.Mul(number.Div(number.Max(number.Sub(penetration, penetrationSlop), 0), number.Add(a.imass, b.imass)), penetrationPercent)
	var correction = normal.Mul(s)
	a.pos = a.pos.Sub(correction.Mul(a.imass))
	b.pos = b.pos.Add(correction.Mul(b.imass))

func resolve():
	var relVel = b.vel.Sub(a.vel)
	var contactVel = relVel.Dot(normal)
	if contactVel > 0:
		return
	var e = number.Min(a.rest, b.rest)
	var j = number.Mul(-number.Add(number.ONE, e), contactVel)
	j = number.Div(j, number.Add(a.imass, b.imass))
	var impulse = normal.Mul(j)
	a.vel = a.vel.Sub(impulse.Mul(a.imass))
	b.vel = b.vel.Add(impulse.Mul(b.imass))
