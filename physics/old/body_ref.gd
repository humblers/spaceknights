extends Reference

const vec2 = preload("res://fixed/vec2_ref.gd")

var gravity = vec2.new(0, number.FromInt(50))
var restitution = number.Div(number.ONE, number.TWO)	# 0.5
var dt = number.Div(number.ONE, number.FromInt(60))		# 1/60

var id = 0
var mass = 0
var imass = 0
var rest = 0
var vel = vec2.new(0, 0)
var pos = vec2.new(0, 0)
var force = vec2.new(0, 0)

# client only
var node
var prev_pos = vec2.new(0, 0)

func Id():
	return id

func _init(id, mass, pos):
	self.id = id
	self.mass = mass
	self.imass = 0 if mass == 0 else number.Div(number.ONE, mass)
	self.rest = restitution
	self.pos = vec2.new(pos.X, pos.Y)
	self.prev_pos = vec2.new(pos.X, pos.Y)

func applyForce():
	if mass == 0:
		return
	var accel = force.Mul(imass).Add(gravity)
	vel = vel.Add(accel.Mul(dt))
	force.X = 0
	force.Y = 0
	
func move():
	if mass == 0:
		return
	pos = pos.Add(vel.Mul(dt))
