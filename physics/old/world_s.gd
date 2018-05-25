extends Reference

const body = preload("res://physics/body_s.gd")
const collision = preload("res://physics/collision_s.gd")

const ITERATIONS = 3

var counter = 0
var bodies = []
var collisions = []

func Step():
	collisions.clear()
	for i in range(len(bodies)):
		for j in range(i + 1, len(bodies)):
			var a = bodies[i]
			var b = bodies[j]
			var c = checkCollision(a, b)
			if c != null:
				collisions.append(c)
	for b in bodies:
		b.applyForce()
	for i in range(ITERATIONS):
		for c in collisions:
			c.resolve()
	for b in bodies:
		b.prev_pos_x = b.pos_x
		b.prev_pos_y = b.pos_y
		b.move()
	for c in collisions:
		c.positionalCorrect()

func AddCircle(mass, radius, pos_x, pos_y):
	var c = circle.new(counter, mass, pos_x, pos_y, radius)
	bodies.append(c)
	counter = counter + 1
	return c

func AddBox(mass, width, height, pos_x, pos_y):
	var b = box.new(counter, mass, pos_x, pos_y, width, height)
	bodies.append(b)
	counter = counter + 1
	return b

func RemoveBody(body):
	for i in range(len(bodies)):
		var b = bodies[i]
		if b.Id() == body.Id():
			bodies[i] = bodies[len(bodies) - 1]
			bodies.pop_back()
			return

class box extends "body_s.gd":
	var width
	var height
	func _init(id, mass, pos_x, pos_y, w, h).(id, mass, pos_x, pos_y):
		width = w
		height = h

class circle extends "body_s.gd":
	var radius
	func _init(id, mass, pos_x, pos_y, r).(id, mass, pos_x, pos_y):
		radius = r

func checkCollision(a, b):
	if a is box:
		if b is box:
			return boxVSbox(a, b)
		if b is circle:
			return boxVScircle(a, b)
	if a is circle:
		if b is box:
			return boxVScircle(b, a)
		if b is circle:
			return circleVScircle(a, b)
	print("unknown shapes")

func boxVSbox(a, b):
	var relPos_x = number.Sub(b.pos_x, a.pos_x)
	var relPos_y = number.Sub(b.pos_y, a.pos_y)
	var overlapX = number.Sub(number.Add(a.width, b.width), number.Abs(relPos_x))
	if overlapX > 0:
		var overlapY = number.Sub(number.Add(a.height, b.height), number.Abs(relPos_y))
		if overlapY > 0:
			var c = collision.new(a, b)
			if overlapX < overlapY:
				c.penetration = overlapX
				if relPos_x < 0:
					c.normal_x = -number.ONE
					c.normal_y = 0
				else:
					c.normal_x = number.ONE
					c.normal_y = 0
				return c
			else:
				c.penetration = overlapY
				if relPos_y < 0:
					c.normal_x = 0
					c.normal_y = -number.ONE
				else:
					c.normal_x = 0
					c.normal_y = number.ONE
			return c
	return null

func circleVScircle(a, b):
	var relPos_x = number.Sub(b.pos_x, a.pos_x)
	var relPos_y = number.Sub(b.pos_y, a.pos_y)
	var radii = number.Add(a.radius, b.radius)
	var d = number.Add(number.Mul(relPos_x, relPos_x), number.Mul(relPos_y, relPos_y))
	if d < number.Mul(radii, radii):
		d = number.Sqrt(d)
		var c = collision.new(a, b)
		c.penetration = number.Sub(radii, d)
		if d != 0:
			c.normal_x = number.Div(relPos_x, d)
			c.normal_y = number.Div(relPos_y, d)
		else:
			c.normal_x = number.ONE
			c.normal_y = 0
		return c
	return null

func boxVScircle(a, b):
	var relPos_x = number.Sub(b.pos_x, a.pos_x)
	var relPos_y = number.Sub(b.pos_y, a.pos_y)
	var closest_x = relPos_x
	var closest_y = relPos_y
	var xExtent = a.width
	var yExtent = a.height
	closest_x = number.Clamp(closest_x, -xExtent, xExtent)
	closest_y = number.Clamp(closest_y, -yExtent, yExtent)
	var inside = false
	var xDist = 0
	var yDist = 0
	if relPos_x == closest_x and relPos_y == closest_y:
		inside = true
		xDist = number.Sub(xExtent, number.Abs(closest_x))
		yDist = number.Sub(yExtent, number.Abs(closest_y))
		if xDist < yDist:
			closest_x = xExtent if relPos_x > 0 else -xExtent
		else:
			closest_y = yExtent if relPos_y > 0 else -yExtent
	var normal_x = number.Sub(relPos_x, closest_x)
	var normal_y = number.Sub(relPos_y, closest_y)
	var d = number.Add(number.Mul(normal_x, normal_x), number.Mul(normal_y, normal_y))
	var r = b.radius
	if d > number.Mul(r, r) && not inside:
		return null
	var c = collision.new(a, b)
	d = number.Sqrt(d)
	if d == 0:
		if xDist == 0:
			c.normal_x = number.ONE if relPos_x > 0 else -number.ONE
			c.normal_y = 0
		else:
			c.normal_x = 0
			c.normal_y = number.ONE if relPos_y > 0 else -number.ONE
	else:
		c.normal_x = number.Div(normal_x, -d if inside else d)
		c.normal_y = number.Div(normal_y, -d if inside else d)
	c.penetration = r + (d if inside else - d)
	return c
