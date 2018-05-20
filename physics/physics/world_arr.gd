extends Reference

const vec2 = preload("res://fixed/vec2_arr.gd")
const body = preload("res://physics/body_arr.gd")
const collision = preload("res://physics/collision_arr.gd")

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
		b.prev_pos = vec2.New(b.pos[0], b.pos[1])
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

class box extends "body_arr.gd":
	var width
	var height
	func _init(id, mass, pos, w, h).(id, mass, pos):
		width = w
		height = h

class circle extends "body_arr.gd":
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
	var relPos = vec2.Sub(b.pos, a.pos)
	var overlapX = number.Sub(number.Add(a.width, b.width), number.Abs(relPos[0]))
	if overlapX > 0:
		var overlapY = number.Sub(number.Add(a.height, b.height), number.Abs(relPos[1]))
		if overlapY > 0:
			var c = collision.new(a, b)
			if overlapX < overlapY:
				c.penetration = overlapX
				if relPos[0] < 0:
					c.normal = vec2.New(-number.ONE, 0)
				else:
					c.normal = vec2.New(number.ONE, 0)
				return c
			else:
				c.penetration = overlapY
				if relPos[1] < 0:
					c.normal = vec2.New(0, -number.ONE)
				else:
					c.normal = vec2.New(0, number.ONE)
			return c
	return null

func circleVScircle(a, b):
	var relPos = vec2.Sub(b.pos, a.pos)
	var radii = number.Add(a.radius, b.radius)
	var d = vec2.LengthSquared(relPos)
	if d < number.Mul(radii, radii):
		d = number.Sqrt(d)
		var c = collision.new(a, b)
		c.penetration = number.Sub(radii, d)
		if d != 0:
			c.normal = vec2.Div(relPos, d)
		else:
			c.normal = vec2.New(number.ONE, 0)
		return c
	return null

func boxVScircle(a, b):
	var relPos = vec2.Sub(b.pos, a.pos)
	var closest = vec2.New(relPos[0], relPos[1])
	var xExtent = a.width
	var yExtent = a.height
	closest[0] = number.Clamp(closest[0], -xExtent, xExtent)
	closest[1] = number.Clamp(closest[1], -yExtent, yExtent)
	var inside = false
	var xDist = 0
	var yDist = 0
	if vec2.Equal(relPos, closest):
		inside = true
		xDist = number.Sub(xExtent, number.Abs(closest[0]))
		yDist = number.Sub(yExtent, number.Abs(closest[1]))
		if xDist < yDist:
			closest[0] = xExtent if relPos[0] > 0 else -xExtent
		else:
			closest[1] = yExtent if relPos[1] > 0 else -yExtent
	var normal = vec2.Sub(relPos, closest)
	var d = vec2.LengthSquared(normal)
	var r = b.radius
	if d > number.Mul(r, r) && not inside:
		return null
	var c = collision.new(a, b)
	d = number.Sqrt(d)
	if d == 0:
		if xDist == 0:
			c.normal = vec2.New(number.ONE if relPos[0] > 0 else -number.ONE, 0)
		else:
			c.normal = vec2.New(0, number.ONE if relPos[1] > 0 else -number.ONE)
	else:
		c.normal = vec2.Div(normal, -d if inside else d)
	c.penetration = r + (d if inside else - d)
	return c
