extends Node

const TO_THRESHOLD = 0.5

onready var starting = get_node("Starting")
onready var threshold = get_node("Threshold").get_pos().y
onready var units = get_node("Units")

func _ready():
	pass

func _process(delta):
	var pos = units.get_pos()
	pos.y -= delta * (starting.get_pos().y - threshold) / TO_THRESHOLD
	if pos.y <= threshold:
		pos.y = threshold
	units.set_pos(pos)

func set_starting_point_x(point):
	var pos = starting.get_pos()
	pos.x = point
	starting.set_pos(pos)

func create_unit(name, offset):
	var spr = Sprite.new()
	spr.set_texture(load("res://unit/%s/blue_idle.png" % name))
	spr.set_pos(offset * global.UNITS[name].radius)
	units.add_child(spr)

func show(card):
	if card == "archers":
		create_unit("archer", Vector2(1, 0))
		create_unit("archer", Vector2(-1, 0))
	elif card == "barbarians":
		pass
	units.set_pos(starting.get_pos())
	units.show()
	set_process(true)

func hide():
	set_process(false)
	units.hide()
	for child in units.get_children():
		child.queue_free()