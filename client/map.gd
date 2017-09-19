extends Node

# layers
var layer = {
	"Ground": 0,
	"Air": 1,
	"UI": 100,
}

onready var WIDTH = Globals.get("display/width")
onready var HEIGHT = Globals.get("display/height") - get_node("MothershipBG").get_texture().get_size().height

func _ready():
	kcp.connect("packet_received", self, "update")

func update(game):
	delete_dead_units(game.Units)

	var my_team = "Home" if game.has("Home") else "Visitor"
	for id in game.Units:
		var unit = game.Units[id]
		var color = get_unit_color(unit, my_team)
		var position = get_unit_position(unit, my_team)
		var rotation = get_unit_rotation(unit, my_team)
		if not get_node("Units").has_node(id):
			create_unit(id, game.Units[id])
		var node = get_node("Units").get_node(id)
		node.get_node(color).show()
		node.set_pos(position)
		node.get_node(color).get_node("Animation").set_rot(rotation)
		node.set_z(layer[unit.Layer])
		node.get_node("Hp").get_node("Label").set_text(str(unit.Hp))
		node.get_node("Hp").set_z(layer.UI)
		node.get_node(color).get_node("Animation").play(unit.State)

func delete_dead_units(units):
	for node in get_node("Units").get_children():
		if not units.has(node.get_name()):
			node.queue_free()

func create_unit(id, unit):
	var node = load("res://unit/" + unit.Name + ".tscn").instance()
	node.set_name(id)
	node.name = unit.Name
	get_node("Units").add_child(node)

func get_unit_color(unit, my_team):
	return "Blue" if unit.Team == my_team else "Red"

func get_unit_position(unit, my_team):
	var x = unit.Position.X
	var y = unit.Position.Y
	if my_team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(WIDTH - x, HEIGHT - y)

func get_unit_rotation(unit, my_team):
	var angle = atan2(unit.Heading.X, unit.Heading.Y)
	if my_team == "Home":
		return angle
	else:
		return angle + PI