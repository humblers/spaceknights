extends Reference

const vec2 = preload("res://fixed/vec2_ref.gd")
const body = preload("res://physics/body.gd")
const collision = preload("res://physics/collision.gd")

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
		b.prev_pos = vec2.new(b.pos.X, b.pos.Y)
		b.move()
	for c in collisions:
		c.positionalCorrect()

func AddCircle(mass, radius, pos):
	var c = circle.new(counter, mass, pos, radius)
	bodies.append(c)
	counter = counter + 1
	return c

func AddBox(mass, width, height, pos):
	var b = box.new(counter, mass, pos, width, height)
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

class box extends "body.gd":
	var width
	var height
	func _init(id, mass, pos, w, h).(id, mass, pos):
		width = w
		height = h

class circle extends "body.gd":
	var radius
	func _init(id, mass, pos, r).(id, mass, pos):
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
	var relPos = b.pos.Sub(a.pos)
	var overlapX = number.Sub(number.Add(a.width, b.width), number.Abs(relPos.X))
	if overlapX > 0:
		var overlapY = number.Sub(number.Add(a.height, b.height), number.Abs(relPos.Y))
		if overlapY > 0:
			var c = collision.new(a, b)
			if overlapX < overlapY:
				c.penetration = overlapX
				if relPos.X < 0:
					c.normal = vec2.new(-number.ONE, 0)
				else:
					c.normal = vec2.new(number.ONE, 0)
				return c
			else:
				c.penetration = overlapY
				if relPos.Y < 0:
					c.normal = vec2.new(0, -number.ONE)
				else:
					c.normal = vec2.new(0, number.ONE)
			return c
	return null

func circleVScircle(a, b):
	var relPos = b.pos.Sub(a.pos)
	var radii = number.Add(a.radius, b.radius)
	var d = relPos.LengthSquared()
	if d < number.Mul(radii, radii):
		d = number.Sqrt(d)
		var c = collision.new(a, b)
		c.penetration = number.Sub(radii, d)
		if d != 0:
			c.normal = relPos.Div(d)
		else:
			c.normal = vec2.new(number.ONE, 0)
		return c
	return null

func boxVScircle(a, b):
	var relPos = b.pos.Sub(a.pos)
	var closest = vec2.new(relPos.X, relPos.Y)
	var xExtent = a.width
	var yExtent = a.height
	closest.X = number.Clamp(closest.X, -xExtent, xExtent)
	closest.Y = number.Clamp(closest.Y, -yExtent, yExtent)
	var inside = false
	if relPos.Equal(closest):
		inside = true
		var xDist = number.Sub(xExtent, number.Abs(closest.X))
		var yDist = number.Sub(yExtent, number.Abs(closest.Y))
		if xDist < yDist:
			closest.X = xExtent if relPos.X > 0 else -xExtent
		else:
			closest.Y = yExtent if relPos.Y > 0 else -yExtent
	var normal = relPos.Sub(closest)
	var d = normal.LengthSquared()
	var r = b.radius
	if d > number.Mul(r, r) && not inside:
		return null
	var c = collision.new(a, b)
	d = number.Sqrt(d)
	c.penetration = r + (d if inside else - d)
	if d != 0:
		c.normal = normal.Div(-d if inside else d)
	else:
		if closest.X == xExtent:
			c.normal = vec2.new(number.ONE, 0)
		elif closest.X == -xExtent:
			c.normal = vec2.new(-number.ONE, 0)
		elif closest.Y == yExtent:
			c.normal = vec2.new(0, number.ONE)
		elif closest.Y == -yExtent:
			c.normal = vec2.new(0, -number.ONE)
		else:
			assert("unknown box vs circle collision, should not be here")
	return c
