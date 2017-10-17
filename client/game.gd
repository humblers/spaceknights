extends Node

const UNIT_DEFAULT = "default"
const UNIT_LAUNCHING = "launching"

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
		create_card_effect(dict)

func delete_dead_units(units):
	for node in get_node("Units").get_children():
		if node.is_in_group(UNIT_LAUNCHING):
			continue
		if not units.has(node.get_name()):
			var effect = load("res://effect/explosion.tscn").instance()
			effect.initialize(node.get_pos(), global.dict_get(global.UNITS, "size", "small"))
			add_child(effect)
			node.queue_free()

func create_new_units(units):
	for id in units:
		if not get_node("Units").has_node(id):
			var unit = units[id]
			create_unit_node(id, unit)

func update_units(units):
	for id in units:
		var node = get_node("Units").get_node(id)
		if node.is_in_group(UNIT_LAUNCHING):
			node.remove_from_group(UNIT_LAUNCHING)
		var unit = units[id]
		node.update_changes(unit)
		if unit.Team == global.team and unit.Name in ["shuriken", "space_z"]:
			get_node("UI/CardGuide").set_starting_x(unit.Position.X)

func create_unit_node(id, unit, group=UNIT_DEFAULT, offset=Vector2(0, 0)):
	var name = unit.Name
	unit = global.clone(unit)
	unit.Position.X += offset.x * global.dict_get(global.UNITS[name], "radius", 0)
	unit.Position.Y += offset.y * global.dict_get(global.UNITS[name], "radius", 0)
	var node = load("res://unit/%s/%s.tscn" % [name, name]).instance()
	node.initialize(unit)
	node.set_name(str(id))
	node.connect("projectile_created", self, "create_projectile")
	get_node("Units").add_child(node)
	if group == UNIT_LAUNCHING:
		if unit.Team == "Home":
			unit.Position.Y = global.MAP.height - unit.Position.Y
		node.set_launch_effect(unit)
		node.add_to_group(group)

func create_card_effect(card):
	if card.Name == "archers":
		card.Name = "archer"
		create_unit_node(card.IdStarting, card, UNIT_LAUNCHING, Vector2(1, 0))
		create_unit_node(card.IdStarting + 1, card, UNIT_LAUNCHING, Vector2(-1, 0))
	elif card.Name == "barbarians":
		card.Name = "barbarian"
		create_unit_node(card.IdStarting, card, UNIT_LAUNCHING, Vector2(1, 1))
		create_unit_node(card.IdStarting + 1, card, UNIT_LAUNCHING, Vector2(1, -1))
		create_unit_node(card.IdStarting + 2, card, UNIT_LAUNCHING, Vector2(-1, 1))
		create_unit_node(card.IdStarting + 3, card, UNIT_LAUNCHING, Vector2(-1, -1))
	elif card.Name == "skeletons":
		card.Name = "skeleton"
		create_unit_node(card.IdStarting, card, UNIT_LAUNCHING, Vector2(0, 1))
		create_unit_node(card.IdStarting + 1, card, UNIT_LAUNCHING, Vector2(1, -1))
		create_unit_node(card.IdStarting + 2, card, UNIT_LAUNCHING, Vector2(-1, -1))
	elif card.Name == "speargoblins":
		card.Name = "speargoblin"
		create_unit_node(card.IdStarting, card, UNIT_LAUNCHING, Vector2(0, 1))
		create_unit_node(card.IdStarting + 1, card, UNIT_LAUNCHING, Vector2(1, -1))
		create_unit_node(card.IdStarting + 2, card, UNIT_LAUNCHING, Vector2(-1, -1))
	else:
		create_unit_node(card.IdStarting, card, UNIT_LAUNCHING)

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
