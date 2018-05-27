extends Reference

var gravity_x = 0
var gravity_y = number.FromInt(50)
var restitution = number.Div(number.ONE, number.TWO)	# 0.5
var dt = number.Div(number.ONE, number.FromInt(60))		# 1/60

var id = 0
var mass = 0
var imass = 0
var rest = 0
var vel_x = 0
var vel_y = 0
var pos_x = 0
var pos_y = 0
var force_x = 0
var force_y = 0

# client only
var node
var prev_pos_x = 0
var prev_pos_y = 0

func Id():
	return id

func _init(id, mass, pos_x, pos_y):
	self.id = id
	self.mass = mass
	self.imass = 0 if mass == 0 else number.Div(number.ONE, mass)
	self.rest = restitution
	self.pos_x = pos_x
	self.pos_y = pos_y
	self.prev_pos_x = pos_x
	self.prev_pos_y = pos_y

func applyForce():
	if mass == 0:
		return
	var accel_x = number.Add(number.Mul(force_x, imass), gravity_x)
	var accel_y = number.Add(number.Mul(force_y, imass), gravity_y)
	vel_x = number.Add(vel_x, number.Mul(accel_x, dt))
	vel_y = number.Add(vel_y, number.Mul(accel_y, dt))
	force_x = 0
	force_y = 0
	
func move():
	if mass == 0:
		return
	pos_x = number.Add(pos_x, number.Mul(vel_x, dt))
	pos_y = number.Add(pos_y, number.Mul(vel_y, dt))
