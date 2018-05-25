extends Node

const ITERATIONS = 3

###### body #######
var gravity_x = 0
var gravity_y = number.FromInt(50)
var restitution = number.Div(number.ONE, number.TWO)	# 0.5
var dt = number.Div(number.ONE, number.FromInt(60))		# 1/60

func newBody(id, mass, pos_x, pos_y):
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

func applyForce(b):
	if b.mass == 0:
		return
	var accel_x = number.Add(number.Mul(b.force_x, b.imass), gravity_x)
	var accel_y = number.Add(number.Mul(b.force_y, b.imass), gravity_y)
	b.vel_x = number.Add(b.vel_x, number.Mul(accel_x, dt))
	b.vel_y = number.Add(b.vel_y, number.Mul(accel_y, dt))
	b.force_x = 0
	b.force_y = 0

func move(b):
	if b.mass == 0:
		return
	b.pos_x = number.Add(b.pos_x, number.Mul(b.vel_x, dt))
	b.pos_y = number.Add(b.pos_y, number.Mul(b.vel_y, dt))


###### collision #######
var penetrationPercent = number.Div(number.ONE, number.FromInt(5))		# 0.2
var penetrationSlop = number.Div(number.ONE, number.FromInt(100))		# 0.01

func newCollision(a, b):
	return {
		"a": a,
		"b": b,
		"normal_x": 0,
		"normal_y": 0,
		"penetration": 0,
	}
	
func positionalCorrect(c):
	var s = number.Mul(number.Div(number.Max(number.Sub(c.penetration, penetrationSlop), 0), number.Add(c.a.imass, c.b.imass)), penetrationPercent)
	var correction_x = number.Mul(c.normal_x, s)
	var correction_y = number.Mul(c.normal_y, s)
	c.a.pos_x = number.Sub(c.a.pos_x, number.Mul(correction_x, c.a.imass))
	c.a.pos_y = number.Sub(c.a.pos_y, number.Mul(correction_y, c.a.imass))
	c.b.pos_x = number.Add(c.b.pos_x, number.Mul(correction_x, c.b.imass))
	c.b.pos_y = number.Add(c.b.pos_y, number.Mul(correction_y, c.b.imass))

func resolve(c):
	var relVel_x = number.Sub(c.b.vel_x, c.a.vel_x)
	var relVel_y = number.Sub(c.b.vel_y, c.a.vel_y)
	var contactVel = number.Add(number.Mul(relVel_x, c.normal_x), number.Mul(relVel_y, c.normal_y))
	if contactVel > 0:
		return
	var e = number.Min(c.a.rest, c.b.rest)
	var j = number.Mul(-number.Add(number.ONE, e), contactVel)
	j = number.Div(j, number.Add(c.a.imass, c.b.imass))
	var impulse_x = number.Mul(c.normal_x, j)
	var impulse_y = number.Mul(c.normal_y, j)
	c.a.vel_x = number.Sub(c.a.vel_x, number.Mul(impulse_x, c.a.imass))
	c.a.vel_y = number.Sub(c.a.vel_y, number.Mul(impulse_y, c.a.imass))
	c.b.vel_x = number.Add(c.b.vel_x, number.Mul(impulse_x, c.b.imass))
	c.b.vel_y = number.Add(c.b.vel_y, number.Mul(impulse_y, c.b.imass))	


###### world #######
func NewWorld():
	return {
		"counter": 0,
		"bodies": [],
		"collisions": [],
	}
	
func Step(w):
	w.collisions.clear()
	for i in range(len(w.bodies)):
		for j in range(i + 1, len(w.bodies)):
			var a = w.bodies[i]
			var b = w.bodies[j]
			var c = checkCollision(a, b)
			if c != null:
				w.collisions.append(c)
	for b in w.bodies:
		applyForce(b)
	for i in range(ITERATIONS):
		for c in w.collisions:
			resolve(c)
	for b in w.bodies:
		b.prev_pos_x = b.pos_x
		b.prev_pos_y = b.pos_y
		move(b)
	for c in w.collisions:
		positionalCorrect(c)

func AddCircle(w, mass, pos_x, pos_y, radius):
	var b = newBody(w.counter, mass, pos_x, pos_y)
	b["shape"] = "circle"
	b["radius"] = radius
	w.bodies.append(b)
	w.counter = w.counter + 1
	return b

func AddBox(w, mass, pos_x, pos_y, width, height):
	var b = newBody(w.counter, mass, pos_x, pos_y)
	b["shape"] = "box"
	b["width"] = width
	b["height"] = height
	w.bodies.append(b)
	w.counter = w.counter + 1
	return b

func RemoveBody(w, body):
	for i in range(len(w.bodies)):
		var b = w.bodies[i]
		if b.id == body.id:
			w.bodies[i] = w.bodies[len(w.bodies) - 1]
			w.bodies.pop_back()
			return

func checkCollision(a, b):
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

func boxVSbox(a, b):
	var relPos_x = number.Sub(b.pos_x, a.pos_x)
	var relPos_y = number.Sub(b.pos_y, a.pos_y)
	var overlapX = number.Sub(number.Add(a.width, b.width), number.Abs(relPos_x))
	if overlapX > 0:
		var overlapY = number.Sub(number.Add(a.height, b.height), number.Abs(relPos_y))
		if overlapY > 0:
			var c = newCollision(a, b)
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
		var c = newCollision(a, b)
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
	var c = newCollision(a, b)
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
