extends Node

const TO_THRESHOLD = 0.5

var starting_y = global.MAP.height - global.MOTHERSHIP_BASE_HEIGHT
onready var card_manager = get_tree().get_root().get("card_manager")
onready var threshold = get_node("Threshold").get_pos().y
onready var base = get_node("Base")

func _process(delta):
	var pos = base.get_pos()
	pos.y -= delta * (starting_y - threshold) / TO_THRESHOLD
	if pos.y <= threshold:
		pos.y = threshold
	base.set_pos(pos)

func set_starting_x(point):
	base.set_pos(Vector2(point, base.get_pos().y))

func create_unit(unit):
	var name = unit.Name
	var node = resource.unit[name].instance()
	node.initialize(unit)
	base.add_child(node)
	node.transform_to_guide_node(Vector2(unit.Position.X, unit.Position.Y))

func show(card):
	var units = global.get_structures_of_unit( {
		"Name" : card,
		"Team" : "",
		"Position" : {
			"X" : 0, "Y" : 0,
		},
	} )
	for unit in units:
		unit.Team = global.team
		create_unit(unit)
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