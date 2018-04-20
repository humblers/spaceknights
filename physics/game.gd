extends Node

const SCALE = 1
const FRAME_PER_STEP = 1
const AI_STEP_PER_PHYSICS_STEP = 1

var frame = 0
var elapsed = 0

func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	CreateWorld()

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		var n = preload("res://unit.tscn").instance()
		n.position = event.position
		add_child(n)

func CreateWorld():
	# shield
	for i in range(3):
		var x
		var width
		if i == 0:
			x = 75
			width = 75
		elif i == 1:
			x = 500
			width = 250
		else:
			x = 925
			width = 75
		var b = Physics.CreateBox(Q.FromInt(0),
			PixelToWorldPosition(Vector2(x, 850)),
			PixelToWorldValue(width),
			PixelToWorldValue(50))
		var n = preload("res://box.tscn").instance()
		n.width = width
		n.height = 50
		add_child(n)
		b.Node = n
	# enemy
	var n = preload("res://enemy.tscn").instance()
	add_child(n)

func _physics_process(delta):
	if frame % (FRAME_PER_STEP * AI_STEP_PER_PHYSICS_STEP) == 0:
		for c in get_children():
			if c.has_method("Step"):
				c.Step()
	if frame % FRAME_PER_STEP == 0:
		Physics.Step()
		elapsed = 0
	frame += 1

func _process(delta):
	elapsed += delta
	var t = elapsed / (float(FRAME_PER_STEP) / Engine.iterations_per_second)
	for body in Physics.bodies.values():
		var prev = WorldToPixelPosition(body.PrevPosition)
		var curr = WorldToPixelPosition(body.Position)
		body.Node.position = prev.linear_interpolate(curr, t)

func PixelToWorldValue(v):
	return Q.Div(Q.FromInt(v), Q.FromInt(SCALE))

func WorldToPixelValue(v):
	return Q.ToFloat(v)

func PixelToWorldPosition(p):
	#var x = int(p.x - width/2) / SCALE
	#var y = int(p.y - height/2) / SCALE
	var x = int(p.x)
	var y = int(p.y)
	return Vec2.Create(Q.FromInt(x), Q.FromInt(y))

func WorldToPixelPosition(p):
	#var x = Q.ToFloat(p.X) * SCALE + width/2
	#var y = Q.ToFloat(p.Y) * SCALE + height/2
	var x = Q.ToFloat(p.X)
	var y = Q.ToFloat(p.Y)
	return Vector2(x, y)
