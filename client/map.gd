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
		if not get_node("Units").has_node(id):
			create_unit(id, game.Units[id], my_team)
		var pos = get_unit_position(unit, my_team)
		get_node("Units").get_node(id).process(unit, my_team, pos)

func delete_dead_units(units):
	for node in get_node("Units").get_children():
		if not units.has(node.get_name()):
			node.is_dead = true
			node.queue_free()

func create_unit(id, unit, my_team):
	var node = load("res://unit/" + unit.Name + ".tscn").instance()
	node.initialize(id, unit, my_team, layer[unit.Layer], layer.UI)
	node.connect("create_projectile", self, "create_projectile")
	get_node("Units").add_child(node)

func create_projectile(type, pos, targetid, hitafter):
	if not get_node("Units").has_node(targetid):
		return
	var node = load("res://projectile/" + type + ".tscn").instance()
	node.initialize(pos, get_node("Units").get_node(targetid), hitafter)
	get_node("Projectiles").add_child(node)

func get_unit_position(unit, my_team):
	var x = unit.Position.X
	var y = unit.Position.Y
	if my_team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(WIDTH - x, HEIGHT - y)