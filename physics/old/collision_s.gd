extends Reference

var penetrationPercent = number.Div(number.ONE, number.FromInt(5))		# 0.2
var penetrationSlop = number.Div(number.ONE, number.FromInt(100))		# 0.01

var a
var b
var normal_x = 0
var normal_y = 0
var penetration = 0

func _init(a, b):
	self.a = a
	self.b = b

func positionalCorrect():
	var s = number.Mul(number.Div(number.Max(number.Sub(penetration, penetrationSlop), 0), number.Add(a.imass, b.imass)), penetrationPercent)
	var correction_x = number.Mul(normal_x, s)
	var correction_y = number.Mul(normal_y, s)
	a.pos_x = number.Sub(a.pos_x, number.Mul(correction_x, a.imass))
	a.pos_y = number.Sub(a.pos_y, number.Mul(correction_y, a.imass))
	b.pos_x = number.Add(b.pos_x, number.Mul(correction_x, b.imass))
	b.pos_y = number.Add(b.pos_y, number.Mul(correction_y, b.imass))

func resolve():
	var relVel_x = number.Sub(b.vel_x, a.vel_x)
	var relVel_y = number.Sub(b.vel_y, a.vel_y)
	var contactVel = number.Add(number.Mul(relVel_x, normal_x), number.Mul(relVel_y, normal_y))
	if contactVel > 0:
		return
	var e = number.Min(a.rest, b.rest)
	var j = number.Mul(-number.Add(number.ONE, e), contactVel)
	j = number.Div(j, number.Add(a.imass, b.imass))
	var impulse_x = number.Mul(normal_x, j)
	var impulse_y = number.Mul(normal_y, j)
	a.vel_x = number.Sub(a.vel_x, number.Mul(impulse_x, a.imass))
	a.vel_y = number.Sub(a.vel_y, number.Mul(impulse_y, a.imass))
	b.vel_x = number.Add(b.vel_x, number.Mul(impulse_x, b.imass))
	b.vel_y = number.Add(b.vel_y, number.Mul(impulse_y, b.imass))	
