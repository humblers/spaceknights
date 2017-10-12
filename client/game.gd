extends Node

func _ready():
	randomize()
	kcp.connect("packet_received", self, "update_changes")

func update_changes(key, dict):
	if key == "Game":
		global.team = "Home" if dict.has("Home") else "Visitor"
		create_new_units(dict.Units)
		update_units(dict.Units)
		delete_dead_units(dict.Units)
		update_ui(dict)
	elif key == "Card":
		print("Card packet recv: ", dict)

func delete_dead_units(units):
	for node in get_node("Units").get_children():
		if not units.has(node.get_name()):
			var effect = load("res://effect/explosion.tscn").instance()
			effect.initialize(node.get_pos(), global.dict_get(global.UNITS, "size", "small"))
			add_child(effect)
			node.queue_free()

func create_new_units(units):
	for id in units:
		if not get_node("Units").has_node(id):
			var unit = units[id]
			var node = load("res://unit/%s/%s.tscn" % [unit.Name, unit.Name]).instance()
			node.set_name(id)
			node.initialize(unit)
			node.connect("projectile_created", self, "create_projectile")
			get_node("Units").add_child(node)

func update_units(units):
	for id in units:
		var unit = units[id]
		get_node("Units").get_node(id).update_changes(unit)
		if unit.Team == global.team and unit.Name in ["shuriken", "space_z"]:
			get_node("UI/CardGuide").set_starting_x(unit.Position.X)

func update_ui(game):
	get_node("UI").update_changes(game)

func create_projectile(type, target_id, lifetime, initial_position):
	assert(get_node("Units").has_node(str(target_id)))
	var node = load("res://projectile/" + type + ".tscn").instance()
	var target = get_node("Units").get_node(str(target_id))
	node.initialize(target, lifetime)
	node.set_pos(initial_position)
	node.set_z(global.LAYERS.Projectile)
	get_node("Projectiles").add_child(node)
