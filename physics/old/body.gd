extends Node

var gravity_x = 0
var gravity_y = number.FromInt(50)
var restitution = number.Div(number.ONE, number.TWO)	# 0.5
var dt = number.Div(number.ONE, number.FromInt(60))		# 1/60

static func NewBody(id, mass, pos_x, pos_y):
	return {
		"id": id,
		"mass": mass,
		"imass": 0 if mass == 0 else number.Div(number.ONE, mass),
		"rest": restitution,
		"pos_x": pos_x,
		"pos_y": pos_y,
		"vel_x": 0,
		"vel_y": 0,
		"force_x": 0,
		"force_y": 0,

		# client only
		"prev_pos_x": pos_x,
		"prev_pos_y": pos_y,
		"node": null
	}

static func ApplyForce(b):
	if mass == 0:
		return
	var accel_x = number.Add(number.Mul(force_x, imass), gravity_x)
	var accel_y = number.Add(number.Mul(force_y, imass), gravity_y)
	b.vel_x = number.Add(b.vel_x, number.Mul(accel_x, dt))
	b.vel_y = number.Add(b.vel_y, number.Mul(accel_y, dt))
	b.force_x = 0
	b.force_y = 0	

static func Move(b):
	if mass == 0:
		return
	b.pos_x = number.Add(b.pos_x, number.Mul(vel_x, dt))
	b.pos_y = number.Add(b.pos_y, number.Mul(vel_y, dt))
