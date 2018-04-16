extends Node

#class Box:
#	var Width
#	var Height
#
#class Circle:
#	var Radius
#
#class Collision:
#	var A
#	var B
#	var Normal
#	var Penetration
#
#class Body:
#	var Id
#	var Shape
#	var Mass
#	var Restitution
#	var InvMass
#	var Velocity
#	var Position
#	var PrevPosition
#	var Force
#	var Node

var counter = 0
var bodies = {}
var collisions = []
var dt = Q.Div(Q.ONE, Q.FromInt(60))
var gravityScale = Q.FromInt(50)
var gravity = Vec2.Create(0, Q.Mul(Q.FromInt(10), gravityScale))
var iterations = 3

func CreateCircle(mass, position, radius):
	counter += 1
	var body = {
		"Id": counter,
		"Shape": "Circle",
		"Mass": mass,
		"Restitution": Q.Div(Q.ONE, Q.FromInt(2)),
		"InvMass": 0 if mass == 0 else Q.Div(Q.ONE, mass),
		"Velocity": Vec2.Create(0, 0),
		"Position": Vec2.Create(position.X, position.Y),
		"PrevPosition": Vec2.Create(position.X, position.Y),
		"Force": Vec2.Create(0, 0),
		"Radius": radius,
	}
	bodies[counter] = body
	return body

func CreateBox(mass, position, width, height):
	counter += 1
	var body = {
		"Id": counter,
		"Shape": "Box",
		"Mass": mass,
		"Restitution": Q.Div(Q.ONE, Q.FromInt(2)),
		"InvMass": 0 if mass == 0 else Q.Div(Q.ONE, mass),
		"Velocity": Vec2.Create(0, 0),
		"Position": Vec2.Create(position.X, position.Y),
		"PrevPosition": Vec2.Create(position.X, position.Y),
		"Force": Vec2.Create(0, 0),
		"Width": width,
		"Height": height,
	}
	bodies[counter] = body
	return body

func RemoveBody(body):
	bodies.erase(body.Id)

func Step():
	collisions.clear()
	for a in bodies.values():
		for b in bodies.values():
			if a.Id >= b.Id:
				continue
			var c = CheckCollision(a, b)
			if c.has("Penetration"):
				collisions.append(c)
	for b in bodies.values():
		ApplyForce(b)
	for i in range(iterations):
		for c in collisions:
			ResolveCollision(c)
	for b in bodies.values():
		b.PrevPosition = Vec2.Create(b.Position.X, b.Position.Y)
		Move(b)
	for c in collisions:
		PositionalCorrection(c)
	for b in bodies.values():
		b.Force.X = 0
		b.Force.Y = 0

func Move(b):
	if b.Mass == 0:
		return
	Vec2.AddInplace(b.Position, Vec2.Mul(b.Velocity, dt))

static func CheckCollision(a, b):
	if a.Shape == "Box" && b.Shape == "Box":
		return BoxVsBox(a, b)
	if a.Shape == "Circle" && b.Shape == "Circle":
		return CircleVsCircle(a, b)
	if a.Shape == "Box" && b.Shape == "Circle":
		return BoxVsCircle(a, b)
	if a.Shape == "Circle" && b.Shape == "Box":
		return BoxVsCircle(b, a)

func ApplyForce(b):
	if b.Mass == 0:
		return
	var accel = Vec2.Add(gravity, Vec2.Mul(b.Force, b.InvMass))
	Vec2.AddInplace(b.Velocity, Vec2.Mul(accel, dt))
	
static func BoxVsBox(a, b):
	var c = { "A": a, "B": b }
	var rel_pos = Vec2.Sub(b.Position, a.Position)
	var a_extent = a.Width
	var b_extent = b.Width
	var x_overlap = Q.Sub(Q.Add(a_extent, b_extent), Q.Abs(rel_pos.X))
	if x_overlap > 0:
		a_extent = a.Height
		b_extent = b.Height
		var y_overlap = Q.Sub(Q.Add(a_extent, b_extent), Q.Abs(rel_pos.Y))
		if y_overlap > 0:
			if x_overlap < y_overlap:
				if rel_pos.X < 0:
					c.Normal = Vec2.Create(-Q.ONE, 0)
				else:
					c.Normal = Vec2.Create(Q.ONE, 0)
				c.Penetration = x_overlap
			else:
				if rel_pos.Y < 0:
					c.Normal = Vec2.Create(0, -Q.ONE)
				else:
					c.Normal = Vec2.Create(0, Q.ONE)
				c.Penetration = y_overlap
	return c

static func CircleVsCircle(a, b):
	var c = { "A": a, "B": b }
	var rel_pos = Vec2.Sub(b.Position, a.Position)
	var radii = Q.Add(a.Radius, b.Radius)
	var d_squared = Vec2.LengthSquared(rel_pos)
	if d_squared < Q.Pow2(radii):
		var d = Q.Sqrt(d_squared)
		if d != 0:
			c.Penetration = Q.Sub(radii, d)
			c.Normal = Vec2.Div(rel_pos, d)
		else:
			c.Penetration = a.Radius
			c.Normal = Vec2.Create(Q.ONE, 0)
	return c

static func BoxVsCircle(a, b):
	var c = { "A": a, "B": b }
	var rel_pos = Vec2.Sub(b.Position, a.Position)
	var closest = Vec2.Create(rel_pos.X, rel_pos.Y)
	var x_extent = a.Width
	var y_extent = a.Height
	closest.X = Q.Clamp(closest.X, -x_extent, x_extent)
	closest.Y = Q.Clamp(closest.Y, -y_extent, y_extent)
	var inside = false
	var x_dist = 0
	var y_dist = 0
	if Vec2.Equal(rel_pos, closest):
		inside = true
		x_dist = Q.Sub(x_extent, Q.Abs(closest.X))
		y_dist = Q.Sub(y_extent, Q.Abs(closest.Y))
		if x_dist < y_dist:
			closest.X = x_extent if rel_pos.X > 0 else -x_extent
		else:
			closest.Y = y_extent if rel_pos.Y > 0 else -y_extent
	var normal = Vec2.Sub(rel_pos, closest)
	var d_squared = Vec2.LengthSquared(normal)
	var r = b.Radius
	if d_squared > Q.Pow2(r) and not inside:
		return c
	var d = Q.Sqrt(d_squared)
	if d == 0:
		if x_dist == 0:
			c.Normal = Vec2.Create(Q.ONE if rel_pos.X > 0 else -Q.ONE, 0)
		else:
			c.Normal = Vec2.Create(0, Q.ONE if rel_pos.Y > 0 else -Q.ONE)
	else:
		c.Normal = Vec2.Div(normal, -d if inside else d)
	c.Penetration = r + d if inside else r - d
	return c

static func ResolveCollision(c):
	var a = c.A
	var b = c.B
	var rel_vel = Vec2.Sub(b.Velocity, a.Velocity)
	var contact_vel = Vec2.Dot(rel_vel, c.Normal)
	if contact_vel > 0:
		return
	var e = Q.Min(a.Restitution, b.Restitution)
	var j = Q.Mul(-Q.Add(Q.ONE, e), contact_vel)
	j = Q.Div(j, Q.Add(a.InvMass, b.InvMass))
	var impluse = Vec2.Mul(c.Normal, j)
	Vec2.SubInplace(a.Velocity, Vec2.Mul(impluse, a.InvMass))
	Vec2.AddInplace(b.Velocity, Vec2.Mul(impluse, b.InvMass))

static func PositionalCorrection(collision):
	var a = collision.A
	var b = collision.B
	# 0.25
	var percent = Q.Div(Q.ONE, Q.FromInt(4))
	# 0.0625
	var slop = Q.Div(Q.ONE, Q.FromInt(16))
	var s = Q.Div(Q.Max(Q.Sub(collision.Penetration, slop), 0), Q.Add(a.InvMass, b.InvMass))
	var correction = Vec2.Mul(Vec2.Mul(collision.Normal, percent), s)
	Vec2.SubInplace(a.Position, Vec2.Mul(correction, a.InvMass))
	Vec2.AddInplace(b.Position, Vec2.Mul(correction, b.InvMass))
	
