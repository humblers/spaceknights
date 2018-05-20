extends Node

# default values
var dt = Q.Div(Q.ONE, Q.FromInt(60))		# 1/60
var iterations = 3
var gravity_x = 0
var gravity_y = Q.FromInt(50)
var penetrationPercent = Q.Div(Q.ONE, Q.FromInt(5))	# 0.2
var penetrationSlop = Q.Div(Q.ONE, Q.FromInt(100))	# 0.01
var restitution = Q.Div(Q.ONE, Q.TWO)				# 0.5

func NewWorld(params):
	return {
		"counter": 0,
		"bodies": [],
		"collisions": [],
		"dt": params.dt if params.has("dt") else dt,
		"iterations": params.iterations if params.has("iterations") else iterations,
		"gravity_x": params.gravity_x if params.has("gravity_x") else gravity_x,
		"gravity_y": params.gravity_y if params.has("gravity_y") else gravity_y,
		"penetrationPercent": params.penetrationPercent if params.has("penetrationPercent") else penetrationPercent,
		"penetrationSlop": params.penetrationSlop if params.has("penetrationSlop") else penetrationSlop,
		"restitution": params.restitution if params.has("restitution") else restitution,
	}

func Step(world):
	var collisions = world.collisions
	var bodies = world.bodies
	collisions.clear()
	for i in range(len(bodies)):
		for j in range(i + 1, len(bodies)):
			var a = bodies[i]
			var b = bodies[j]
			var c = checkCollision(a, b)
			if c != null:
				collisions.append(c)
	for b in bodies:
		applyForce(world, b)
	for i in range(world.iterations):
		for c in collisions:
			resolve(c)
	for b in bodies:
		b.prev_pos_x = b.pos_x
		b.prev_pos_y = b.pos_y
		move(world, b)
	for c in collisions:
		positionalCorrect(world, c)

func AddCircle(world, mass, pos_x, pos_y, radius):
	var b = newBody(world.counter, mass, world.restitution, pos_x, pos_y)
	b["shape"] = "circle"
	b["radius"] = radius
	world.bodies.append(b)
	world.counter = world.counter + 1
	return b

func AddBox(world, mass, pos_x, pos_y, width, height):
	var b = newBody(world.counter, mass, world.restitution, pos_x, pos_y)
	b["shape"] = "box"
	b["width"] = width
	b["height"] = height
	world.bodies.append(b)
	world.counter = world.counter + 1
	return b

func RemoveBody(world, body):
	var bodies = world.bodies
	for i in range(len(bodies)):
		if bodies[i].id == body.id:
			bodies[i] = bodies[len(bodies) - 1]
			bodies.pop_back()
			return

func newBody(id, mass, restitution, pos_x, pos_y):
	return {
		"id": id,
		"mass": mass,
		"imass": 0 if mass == 0 else Q.Div(Q.ONE, mass),
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

func applyForce(world, body):
	if body.mass == 0:
		return
	var accel_x = Q.Add(Q.Mul(body.force_x, body.imass), world.gravity_x)
	var accel_y = Q.Add(Q.Mul(body.force_y, body.imass), world.gravity_y)
	body.vel_x = Q.Add(body.vel_x, Q.Mul(accel_x, world.dt))
	body.vel_y = Q.Add(body.vel_y, Q.Mul(accel_y, world.dt))
	body.force_x = 0
	body.force_y = 0

func move(world, body):
	if body.mass == 0:
		return
	body.pos_x = Q.Add(body.pos_x, Q.Mul(body.vel_x, world.dt))
	body.pos_y = Q.Add(body.pos_y, Q.Mul(body.vel_y, world.dt))


func newCollision(a, b):
	return {
		"a": a,
		"b": b,
		"normal_x": 0,
		"normal_y": 0,
		"penetration": 0,
	}
	
func positionalCorrect(world, collision):
	var a = collision.a
	var b = collision.b
	var s = Q.Mul(Q.Div(Q.Max(Q.Sub(collision.penetration, world.penetrationSlop), 0), Q.Add(a.imass, b.imass)), world.penetrationPercent)
	var correction_x = Q.Mul(collision.normal_x, s)
	var correction_y = Q.Mul(collision.normal_y, s)
	a.pos_x = Q.Sub(a.pos_x, Q.Mul(correction_x, a.imass))
	a.pos_y = Q.Sub(a.pos_y, Q.Mul(correction_y, a.imass))
	b.pos_x = Q.Add(b.pos_x, Q.Mul(correction_x, b.imass))
	b.pos_y = Q.Add(b.pos_y, Q.Mul(correction_y, b.imass))

func resolve(collision):
	var a = collision.a
	var b = collision.b
	var relVel_x = Q.Sub(b.vel_x, a.vel_x)
	var relVel_y = Q.Sub(b.vel_y, a.vel_y)
	var contactVel = vec2.Dot(relVel_x, relVel_y, collision.normal_x, collision.normal_y)
	if contactVel > 0:
		return
	var e = Q.Min(a.rest, b.rest)
	var j = Q.Mul(-Q.Add(Q.ONE, e), contactVel)
	j = Q.Div(j, Q.Add(a.imass, b.imass))
	var impulse_x = Q.Mul(collision.normal_x, j)
	var impulse_y = Q.Mul(collision.normal_y, j)
	a.vel_x = Q.Sub(a.vel_x, Q.Mul(impulse_x, a.imass))
	a.vel_y = Q.Sub(a.vel_y, Q.Mul(impulse_y, a.imass))
	b.vel_x = Q.Add(b.vel_x, Q.Mul(impulse_x, b.imass))
	b.vel_y = Q.Add(b.vel_y, Q.Mul(impulse_y, b.imass))	

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
	var relPos_x = Q.Sub(b.pos_x, a.pos_x)
	var relPos_y = Q.Sub(b.pos_y, a.pos_y)
	var overlapX = Q.Sub(Q.Add(a.width, b.width), Q.Abs(relPos_x))
	if overlapX > 0:
		var overlapY = Q.Sub(Q.Add(a.height, b.height), Q.Abs(relPos_y))
		if overlapY > 0:
			var c = newCollision(a, b)
			if overlapX < overlapY:
				c.penetration = overlapX
				if relPos_x < 0:
					c.normal_x = -Q.ONE
					c.normal_y = 0
				else:
					c.normal_x = Q.ONE
					c.normal_y = 0
				return c
			else:
				c.penetration = overlapY
				if relPos_y < 0:
					c.normal_x = 0
					c.normal_y = -Q.ONE
				else:
					c.normal_x = 0
					c.normal_y = Q.ONE
			return c
	return null

func circleVScircle(a, b):
	var relPos_x = Q.Sub(b.pos_x, a.pos_x)
	var relPos_y = Q.Sub(b.pos_y, a.pos_y)
	var radii = Q.Add(a.radius, b.radius)
	var d = vec2.LengthSquared(relPos_x, relPos_y)
	if d < Q.Mul(radii, radii):
		d = Q.Sqrt(d)
		var c = newCollision(a, b)
		c.penetration = Q.Sub(radii, d)
		if d != 0:
			c.normal_x = Q.Div(relPos_x, d)
			c.normal_y = Q.Div(relPos_y, d)
		else:
			c.normal_x = Q.ONE
			c.normal_y = 0
		return c
	return null

func boxVScircle(a, b):
	var relPos_x = Q.Sub(b.pos_x, a.pos_x)
	var relPos_y = Q.Sub(b.pos_y, a.pos_y)
	var closest_x = relPos_x
	var closest_y = relPos_y
	var xExtent = a.width
	var yExtent = a.height
	closest_x = Q.Clamp(closest_x, -xExtent, xExtent)
	closest_y = Q.Clamp(closest_y, -yExtent, yExtent)
	var inside = false
	var xDist = 0
	var yDist = 0
	if relPos_x == closest_x and relPos_y == closest_y:
		inside = true
		xDist = Q.Sub(xExtent, Q.Abs(closest_x))
		yDist = Q.Sub(yExtent, Q.Abs(closest_y))
		if xDist < yDist:
			closest_x = xExtent if relPos_x > 0 else -xExtent
		else:
			closest_y = yExtent if relPos_y > 0 else -yExtent
	var normal_x = Q.Sub(relPos_x, closest_x)
	var normal_y = Q.Sub(relPos_y, closest_y)
	var d = vec2.LengthSquared(normal_x, normal_y)
	var r = b.radius
	if d > Q.Mul(r, r) && not inside:
		return null
	var c = newCollision(a, b)
	d = Q.Sqrt(d)
	c.penetration = r + (d if inside else - d)
	if d != 0:
		c.normal_x = Q.Div(normal_x, -d if inside else d)
		c.normal_y = Q.Div(normal_y, -d if inside else d)
	else:
		if closest_x == xExtent:
			c.normal_x = Q.ONE
			c.normal_y = 0
		elif closest_x == -xExtent:
			c.normal_x = -Q.ONE
			c.normal_y = 0
		elif closest_y == yExtent:
			c.normal_x = 0
			c.normal_y = Q.ONE
		elif closest_y == -yExtent:
			c.normal_x = 0
			c.normal_y = -Q.ONE
		else:
			assert("unknown box vs circle collision, should not be here")
	return c
