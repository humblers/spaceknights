extends Reference

const body = preload("res://game/script/physics/body.gd")
const collision = preload("res://game/script/physics/collision.gd")

var counter = 0
var bodies = []
var collisions = []

var scale = scalar.One
var dt = scalar.Div(scalar.One, scalar.FromInt(10))
var iterations = 3
var gravity_x = 0
var gravity_y = scalar.FromInt(1000)
var restitution = scalar.Div(scalar.One, scalar.Two)
var correctionPercent = scalar.Div(scalar.Two, scalar.FromInt(5))
var correctionThreshold = scalar.Div(scalar.One, scalar.FromInt(100))

func _init(params):
	for k in params:
		var v = params[k]
		match k:
			"scale":
				scale = v
			"dt":
				dt = v
			"gravity_x":
				gravity_x = v
			"gravity_y":
				gravity_y = v
			"restitution":
				restitution = v

func Dt():
	return dt

func FromPixel(v):
	return scalar.Mul(scalar.FromInt(v), scale)
	
func ToPixel(v):
	return scalar.ToInt(scalar.Div(v, scale))

func Step():
	collisions.clear()
	for i in range(len(bodies)):
		for j in range(i + 1, len(bodies)):
			var a = bodies[i]
			var b = bodies[j]
			if a.no_collision or b.no_collision:
				continue
			if a.layer != b.layer:
				continue
			var c = checkCollision(a, b)
			if c != null:
				collisions.append(c)
	for b in bodies:
		b.applyForce(gravity_x, gravity_y, dt)
	for i in range(iterations):
		for c in collisions:
			c.resolve()
	for b in bodies:
		b.move(dt)
	for c in collisions:
		c.positionalCorrect(correctionThreshold, correctionPercent)

func AddBox(mass, width, height, pos_x, pos_y):
	var b = addBody(mass, pos_x, pos_y)
	b.setAsBox(width, height)
	return b

func AddCircle(mass, radius, pos_x, pos_y):
	var b = addBody(mass, pos_x, pos_y)
	b.setAsCircle(radius)
	return b

func addBody(mass, pos_x, pos_y):
	var b = body.new(
		counter,
		mass,
		restitution,
		pos_x,
		pos_y
	)
	bodies.append(b)
	counter = counter + 1
	return b

func RemoveBody(b):
	for i in range(len(bodies)):
		if bodies[i].id == b.Id():
			bodies[i] = bodies[len(bodies) - 1]
			bodies.pop_back()
			return

func Digest(h=djb2.INITIAL_HASH):
	h = djb2.Hash(counter, h)
	for b in bodies:
		h = b.digest(h)
	for c in collisions:
		h = c.digest(h)
	return h

static func checkCollision(a, b):
	if a.shape == "box":
		if b.shape == "box":
			return boxVSbox(a, b)
		if b.shape == "circle":
			return boxVScircle(a, b)
	if a.shape == "circle":
		if b.shape == "box":
			return boxVScircle(b, a)
		if b.shape == "circle":
			return circleVScircle(a, b)
	print("unknown shapes")

static func boxVSbox(a, b):
	var relPos_x = scalar.Sub(b.pos_x, a.pos_x)
	var relPos_y = scalar.Sub(b.pos_y, a.pos_y)
	var overlapX = scalar.Sub(scalar.Add(a.width, b.width), scalar.Abs(relPos_x))
	if overlapX > 0:
		var overlapY = scalar.Sub(scalar.Add(a.height, b.height), scalar.Abs(relPos_y))
		if overlapY > 0:
			var c = collision.new(a, b)
			if overlapX < overlapY:
				c.penetration = overlapX
				if relPos_x < 0:
					c.normal_x = -scalar.One
					c.normal_y = 0
				else:
					c.normal_x = scalar.One
					c.normal_y = 0
				return c
			else:
				c.penetration = overlapY
				if relPos_y < 0:
					c.normal_x = 0
					c.normal_y = -scalar.One
				else:
					c.normal_x = 0
					c.normal_y = scalar.One
			return c
	return null

static func circleVScircle(a, b):
	var relPos_x = scalar.Sub(b.pos_x, a.pos_x)
	var relPos_y = scalar.Sub(b.pos_y, a.pos_y)
	var radii = scalar.Add(a.radius, b.radius)
	var d = vector.LengthSquared(relPos_x, relPos_y)
	if d < scalar.Mul(radii, radii):
		d = scalar.Sqrt(d)
		var c = collision.new(a, b)
		c.penetration = scalar.Sub(radii, d)
		if d != 0:
			c.normal_x = scalar.Div(relPos_x, d)
			c.normal_y = scalar.Div(relPos_y, d)
		else:
			c.normal_x = scalar.One
			c.normal_y = 0
		return c
	return null

static func boxVScircle(a, b):
	var relPos_x = scalar.Sub(b.pos_x, a.pos_x)
	var relPos_y = scalar.Sub(b.pos_y, a.pos_y)
	var closest_x = relPos_x
	var closest_y = relPos_y
	var xExtent = a.width
	var yExtent = a.height
	closest_x = scalar.Clamp(closest_x, -xExtent, xExtent)
	closest_y = scalar.Clamp(closest_y, -yExtent, yExtent)
	var inside = false
	if relPos_x == closest_x and relPos_y == closest_y:
		inside = true
		var xDist = scalar.Sub(xExtent, scalar.Abs(closest_x))
		var yDist = scalar.Sub(yExtent, scalar.Abs(closest_y))
		if xDist < yDist:
			closest_x = xExtent if relPos_x > 0 else -xExtent
		else:
			closest_y = yExtent if relPos_y > 0 else -yExtent
	var normal_x = scalar.Sub(relPos_x, closest_x)
	var normal_y = scalar.Sub(relPos_y, closest_y)
	var d = vector.LengthSquared(normal_x, normal_y)
	var r = b.radius
	if d > scalar.Mul(r, r) && not inside:
		return null
	var c = collision.new(a, b)
	d = scalar.Sqrt(d)
	c.penetration = r + (d if inside else - d)
	if d != 0:
		c.normal_x = scalar.Div(normal_x, -d if inside else d)
		c.normal_y = scalar.Div(normal_y, -d if inside else d)
	else:
		if closest_x == xExtent:
			c.normal_x = scalar.One
			c.normal_y = 0
		elif closest_x == -xExtent:
			c.normal_x = -scalar.One
			c.normal_y = 0
		elif closest_y == yExtent:
			c.normal_x = 0
			c.normal_y = scalar.One
		elif closest_y == -yExtent:
			c.normal_x = 0
			c.normal_y = -scalar.One
		else:
			assert("unknown box vs circle collision, should not be here")
	return c
