extends Node

const TO_THRESHOLD = 0.5

var starting_y = global.MAP.height - global.MOTHERSHIP_BASE_HEIGHT
onready var threshold = get_node("Threshold").get_pos().y
onready var base = get_node("Base")

func _process(delta):
	var pos = base.get_pos()
	pos.y -= delta * (starting_y - threshold) / TO_THRESHOLD
	if pos.y <= threshold:
		pos.y = threshold
	base.set_pos(pos)

func set_starting_x(point):
	if global.team == "Visitor":
		point = global.MAP.width - point
	base.set_pos(Vector2(point, base.get_pos().y))

func create_unit(name, offset=Vector2(0, 0)):
	var unit = {
		"Name": name,
		"Team": global.team,
	}
	var node = load("res://unit/%s/%s.tscn" % [name, name]).instance()
	node.initialize(unit)
	base.add_child(node)
	var pos = Vector2(0, 0) + offset * global.dict_get(global.UNITS[name], "radius", 0)
	node.transform_to_guide_node(pos)

func show(card):
	if card == "archers":
		create_unit("archer", Vector2(1, 0))
		create_unit("archer", Vector2(-1, 0))
	elif card == "barbarians":
		create_unit("barbarian", Vector2(1, 1))
		create_unit("barbarian", Vector2(1, -1))
		create_unit("barbarian", Vector2(-1, 1))
		create_unit("barbarian", Vector2(-1, -1))
	elif card == "skeletons":
		create_unit("skeleton", Vector2(0, -1))
		create_unit("skeleton", Vector2(1, 1))
		create_unit("skeleton", Vector2(-1, 1))
	elif card == "speargoblins":
		create_unit("speargoblin", Vector2(0, -1))
		create_unit("speargoblin", Vector2(1, 1))
		create_unit("speargoblin", Vector2(-1, 1))
	else:
		create_unit(card)
	base.set_pos(Vector2(base.get_pos().x, starting_y))
	base.show()
	set_process(true)

func hide():
	set_process(false)
	base.hide()
	for child in base.get_children():
		child.queue_free()

func get_release_point():
	return global.MAP.height - base.get_pos().y