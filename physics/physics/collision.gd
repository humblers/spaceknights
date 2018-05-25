extends Reference

var a = null
var b = null
var normal_x = 0
var normal_y = 0
var penetration = 0

func _init(a, b):
	self.a = a
	self.b = b
	
func positionalCorrect(threshold, percent):
	var s = scalar.Max(scalar.Sub(penetration, threshold), 0)
	s = scalar.Mul(scalar.Div(s, scalar.Add(a.imass, b.imass)), percent)
	var correction_x = scalar.Mul(normal_x, s)
	var correction_y = scalar.Mul(normal_y, s)
	a.pos_x = scalar.Sub(a.pos_x, scalar.Mul(correction_x, a.imass))
	a.pos_y = scalar.Sub(a.pos_y, scalar.Mul(correction_y, a.imass))
	b.pos_x = scalar.Add(b.pos_x, scalar.Mul(correction_x, b.imass))
	b.pos_y = scalar.Add(b.pos_y, scalar.Mul(correction_y, b.imass))

func resolve():
	var relVel_x = scalar.Sub(b.vel_x, a.vel_x)
	var relVel_y = scalar.Sub(b.vel_y, a.vel_y)
	var separation = vector.Dot(relVel_x, relVel_y, normal_x, normal_y)
	if separation > 0:
		return
	var e = scalar.Min(a.rest, b.rest)
	var j = scalar.Mul(-scalar.Add(scalar.One, e), separation)
	j = scalar.Div(j, scalar.Add(a.imass, b.imass))
	var impulse_x = scalar.Mul(normal_x, j)
	var impulse_y = scalar.Mul(normal_y, j)
	a.vel_x = scalar.Sub(a.vel_x, scalar.Mul(impulse_x, a.imass))
	a.vel_y = scalar.Sub(a.vel_y, scalar.Mul(impulse_y, a.imass))
	b.vel_x = scalar.Add(b.vel_x, scalar.Mul(impulse_x, b.imass))
	b.vel_y = scalar.Add(b.vel_y, scalar.Mul(impulse_y, b.imass))
