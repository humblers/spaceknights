extends Node

# layers
var layer = {
	"Ground": 0,
	"Air": 1,
	"Projectile": 2,
	"UI": 100,
}

onready var WIDTH = Globals.get("display/width")
onready var HEIGHT = Globals.get("display/height") - get_node("MothershipBG").get_texture().get_size().height

func _ready():
	kcp.connect("packet_received", self, "update")

func update(game):
	delete_dead_units(game.Units)

	var user_team = "Home" if game.has("Home") else "Visitor"
	for id in game.Units:
		var unit = game.Units[id]
		if not get_node("Units").has_node(id):
			create_unit(id, game.Units[id], user_team)
	for id in game.Units:
		var unit = game.Units[id]
		var pos = get_unit_position(unit, user_team)
		get_node("Units").get_node(id).process(unit, user_team, pos)

func delete_dead_units(units):
	for node in get_node("Units").get_children():
		if not units.has(node.get_name()):
			node.queue_free()

func create_unit(id, unit, user_team):
	var node = load("res://unit/" + unit.Name + ".tscn").instance()
	node.initialize(id, unit, user_team, layer[unit.Layer], layer.UI)
	node.connect("create_projectile", self, "create_projectile")
	get_node("Units").add_child(node)

func create_projectile(target_id, type, pos, lifetime):
	if target_id <= 0:
		return
	target_id = String(target_id)
	if not get_node("Units").has_node(target_id):
		return
	var node = load("res://projectile/" + type + ".tscn").instance()
	var target = get_node("Units").get_node(target_id)
	node.initialize(target, pos, lifetime, layer.Projectile)
	get_node("Projectiles").add_child(node)

func get_unit_position(unit, user_team):
	var x = unit.Position.X
	var y = unit.Position.Y
	if user_team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(WIDTH - x, HEIGHT - y)