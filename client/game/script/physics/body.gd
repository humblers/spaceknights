extends Reference

var id = 0
var mass = 0
var imass = 0
var rest = 0	# restitution
var pos_x = 0
var pos_y = 0
var vel_x = 0
var vel_y = 0
var force_x = 0
var force_y = 0
var no_collision = false
var layer = ""

# geometry
var shape = ""
var radius = 0
var width = 0
var height = 0

# client only
var prev_pos_x = 0
var prev_pos_y = 0
var node = null

func _init(id, mass, rest, pos_x, pos_y):
	self.id = id
	self.mass = mass
	self.imass = 0 if mass == 0 else scalar.Div(scalar.One, mass)
	self.rest = rest
	self.pos_x = pos_x
	self.pos_y = pos_y
	self.prev_pos_x = self.pos_x
	self.prev_pos_y = self.pos_y

func Id():
	return id

func PositionX():
	return pos_x

func PositionY():
	return pos_y

func SetPosition(x, y):
	pos_x = x
	pos_y = y

func VelocityX():
	return vel_x

func VelocityY():
	return vel_y
	
func SetVelocity(x, y):
	vel_x = x
	vel_y = y

func Radius():
	return radius

func SetCollidable(collidable):
	no_collision = not collidable

func Layer():
	return layer

func SetLayer(l):
	layer = l

func setAsBox(width, height):
	self.shape = "box"
	self.width = width
	self.height = height

func setAsCircle(radius):
	self.shape = "circle"
	self.radius = radius

func applyForce(gravity_x, gravity_y, dt):
	if mass == 0:
		return
	var accel_x = scalar.Add(scalar.Mul(force_x, imass), gravity_x)
	var accel_y = scalar.Add(scalar.Mul(force_y, imass), gravity_y)
	vel_x = scalar.Add(vel_x, scalar.Mul(accel_x, dt))
	vel_y = scalar.Add(vel_y, scalar.Mul(accel_y, dt))
	force_x = 0
	force_y = 0

func move(dt):
	if mass == 0:
		return
	prev_pos_x = pos_x
	prev_pos_y = pos_y
	pos_x = scalar.Add(pos_x, scalar.Mul(vel_x, dt))
	pos_y = scalar.Add(pos_y, scalar.Mul(vel_y, dt))

func digest(h=djb2.INITIAL_HASH):
	var elems = [id, mass, imass, rest,
			[pos_x, pos_y],
			[vel_x, vel_y],
			[force_x, force_y],
			shape, radius, width, height
	]
	for e in elems:
		h = djb2.Hash(e, h)
	return h