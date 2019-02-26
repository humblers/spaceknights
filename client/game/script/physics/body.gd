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
var no_physics = false
var layer = ""
var colliding = false

# geometry
var shape = ""
var radius = 0
var width = 0
var height = 0

# client only
var prev_pos_x = 0
var prev_pos_y = 0
var node = null
var set_position = false

func State():
	return {
		"id": id,
		"mass": mass,
		"imass": imass,
		"rest": rest,
		"pos": {"X": pos_x, "Y": pos_y},
		"vel": {"X": vel_x, "Y": vel_y},
		"force": {"X": force_x, "Y": force_y},
		"shape": shape,
		"radius": radius,
		"width": width,
		"height": height,
		"no_physics": no_physics,
		"layer": layer,
		"colliding": colliding,
	}
	
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
	prev_pos_x = pos_x
	prev_pos_y = pos_y
	pos_x = x
	pos_y = y
	set_position = true

func VelocityX():
	return vel_x

func VelocityY():
	return vel_y
	
func SetVelocity(x, y):
	vel_x = x
	vel_y = y

func Radius():
	return radius

func Simulate(on):
	no_physics = not on

func Layer():
	return layer

func SetLayer(l):
	layer = l

func AddForce(x, y):
	force_x = scalar.Add(force_x, x)
	force_y = scalar.Add(force_y, y)
	
func setAsBox(width, height):
	self.shape = "box"
	self.width = width
	self.height = height

func setAsCircle(radius):
	self.shape = "circle"
	self.radius = radius

func applyForce(gravity_x, gravity_y, dt):
	var accel_x = scalar.Add(scalar.Mul(force_x, imass), gravity_x)
	var accel_y = scalar.Add(scalar.Mul(force_y, imass), gravity_y)
	vel_x = scalar.Add(vel_x, scalar.Mul(accel_x, dt))
	vel_y = scalar.Add(vel_y, scalar.Mul(accel_y, dt))
	force_x = 0
	force_y = 0

func move(dt):
	if mass == 0 or no_physics:
		return
	if not set_position:
		prev_pos_x = pos_x
		prev_pos_y = pos_y
	else:
		set_position = false
	pos_x = scalar.Add(pos_x, scalar.Mul(vel_x, dt))
	pos_y = scalar.Add(pos_y, scalar.Mul(vel_y, dt))

func Hash():
	return djb2.Combine([
		djb2.HashInt(id),
		scalar.Hash(mass),
		scalar.Hash(imass),
		scalar.Hash(rest),
		vector.Hash(pos_x, pos_y),
		vector.Hash(vel_x, vel_y),
		vector.Hash(force_x, force_y),
		djb2.HashString(shape),
		scalar.Hash(radius),
		scalar.Hash(width),
		scalar.Hash(height),
		djb2.HashBool(no_physics),
		djb2.HashString(layer),
		djb2.HashBool(colliding),
	])
