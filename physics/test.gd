extends Node

const scale = 10
var width = ProjectSettings.get("display/window/size/width")
var height = ProjectSettings.get("display/window/size/height")

func _ready():
	set_process_input(true)
	set_physics_process(true)
	set_process(true)
	var b = Physics.CreateBox(Q.FromInt(0),
		PixelToWorldPosition(Vector2(500, 500)),
		PixelToWorldValue(400),
		PixelToWorldValue(20))
	var n = preload("res://box.tscn").instance()
	n.width = 800
	n.height = 40
	n.color = Color(0, 0, 1)
	add_child(n)
	b.Node = n

func _physics_process(delta):
	Physics.Step()

func _process(delta):
	for b in Physics.bodies.values():
		var pos = WorldToPixelPosition(b.Position)
		if pos.x <  0 || pos.x > width || pos.y < 0 || pos.y > height:
			Physics.RemoveBody(b)
			b.Node.queue_free()
		b.Node.position = WorldToPixelPosition(b.Position)

func PixelToWorldValue(v):
	return Q.Div(Q.FromInt(v), Q.FromInt(scale))

func WorldToPixelValue(v):
	return Q.ToFloat(v)

func PixelToWorldPosition(p):
	var x = int(p.x - width/2) / scale
	var y = int(p.y - height/2) / scale
	return Vec2.Create(Q.FromInt(x), Q.FromInt(y))

func WorldToPixelPosition(p):
	var x = Q.ToFloat(p.X) * scale + width/2
	var y = Q.ToFloat(p.Y) * scale + height/2
	return Vector2(x, y)

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_LEFT:
			var b = Physics.CreateCircle(Q.FromInt(5), 
				PixelToWorldPosition(event.position),
				PixelToWorldValue(30))
			var n = preload("res://circle.tscn").instance()
			n.radius = 30
			add_child(n)
			b.Node = n
		if event.button_index == BUTTON_RIGHT:
			var b = Physics.CreateBox(Q.FromInt(10),
				PixelToWorldPosition(event.position),
				PixelToWorldValue(30),
				PixelToWorldValue(30))
			var n = preload("res://box.tscn").instance()
			n.width = 60
			n.height = 60
			add_child(n)
			b.Node = n
