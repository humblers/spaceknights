extends Node

var penetrationPercent = number.Div(number.ONE, number.FromInt(5))		# 0.2
var penetrationSlop = number.Div(number.ONE, number.FromInt(100))		# 0.01

func New(a, b):
	return {
		"a": a,
		"b": b,
		"normal_x": 0,
		"normal_y": 0,
		"penetration": 0,
	}
	
func PositionalCorrect(c):
	var s = number.Mul(number.Div(number.Max(number.Sub(c.penetration, penetrationSlop), 0), number.Add(c.a.imass, c.b.imass)), penetrationPercent)
	var correction_x = number.Mul(c.normal_x, s)
	var correction_y = number.Mul(c.normal_y, s)
	c.a.pos_x = number.Sub(c.a.pos_x, number.Mul(correction_x, c.a.imass))
	c.a.pos_y = number.Sub(c.a.pos_y, number.Mul(correction_y, c.a.imass))
	c.b.pos_x = number.Add(c.b.pos_x, number.Mul(correction_x, c.b.imass))
	c.b.pos_y = number.Add(c.b.pos_y, number.Mul(correction_y, c.b.imass))

func Resolve(c):
	var relVel_x = number.Sub(c.b.vel_x, c.a.vel_x)
	var relVel_y = number.Sub(c.b.vel_y, c.a.vel_y)
	var contactVel = number.Add(number.Mul(relVel_x, c.normal_x), number.Mul(relVel_y, c.normal_y))
	if contactVel > 0:
		return
	var e = number.Min(c.a.rest, c.b.rest)
	var j = number.Mul(-number.Add(number.ONE, e), contactVel)
	j = number.Div(j, number.Add(c.a.imass, c.b.imass))
	var impulse_x = number.Mul(c.normal_x, j)
	var impulse_y = number.Mul(c.normal_y, j)
	c.a.vel_x = number.Sub(c.a.vel_x, number.Mul(impulse_x, c.a.imass))
	c.a.vel_y = number.Sub(c.a.vel_y, number.Mul(impulse_y, c.a.imass))
	c.b.vel_x = number.Add(c.b.vel_x, number.Mul(impulse_x, c.b.imass))
	c.b.vel_y = number.Add(c.b.vel_y, number.Mul(impulse_y, c.b.imass))	
