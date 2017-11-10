extends Node

const UNIT_DEFAULT = "default"
const UNIT_LAUNCHING = "launching"

func _ready():
	get_node("MothershipBG/BlueBaseBottom")
	get_node("OpeningAnim").connect("finished", self, "opening_finished")
	kcp.connect("packet_received", self, "update_changes")

func update_changes(game):
	global.team = "Home" if game.has("Home") else "Visitor"
	create_new_units(game.Units)
	update_units(game.Units)
	delete_dead_units(game.Units)
	handle_waiting_cards(game.Frame, global.dict_get(game, "WaitingCards", []))
	update_ui(game)

func opening_finished():
	get_node("UI").connect_ui_signals()
	get_node("Units").show()
	get_node("OpeningNodes").queue_free()

func has_id(units, id):
	for unit in units:
		if str(unit.Id) == id:
			return true
	return false

func delete_dead_units(units):
	for node in get_node("Units").get_children():
		if node.is_in_group(UNIT_LAUNCHING):
			continue
		if not has_id(units, node.get_name()):
			var effect = load("res://effect/explosion/unit.tscn").instance()
			effect.initialize(global.dict_get(global.UNITS[node.name], "size", "small"), node.get_pos())
			add_child(effect)
			node.queue_free()

func create_new_units(units):
	for unit in units:
		if not get_node("Units").has_node(str(unit.Id)):
			create_unit_node(unit)

func update_units(units):
	for unit in units:
		var node = get_node("Units").get_node(str(unit.Id))
		if node.is_in_group(UNIT_LAUNCHING):
			node.remove_from_group(UNIT_LAUNCHING)
		node.update_changes(unit)
		if unit.Team == global.team and unit.Name in ["shuriken", "space_z"]:
			get_node("UI/CardGuide").set_starting_x(node.get_pos().x)

func create_unit_node(unit, group=UNIT_DEFAULT):
	var name = unit.Name
	var node = load("res://unit/%s/%s.tscn" % [name, name]).instance()
	node.initialize(unit)
	node.set_name(str(unit.Id))
	node.connect("projectile_created", self, "create_projectile")
	get_node("Units").add_child(node)
	if group == UNIT_LAUNCHING:
		node.set_launch_effect(unit)
		node.add_to_group(group)

func handle_waiting_cards(frame, cards):
	for card in cards:
		if frame + global.CARD_WAIT_FRAME == card.ActivateFrame:
			var script = preload("res://card.gd").new()
			var id = card.IdStarting
			var unit_structures = script.get_structures_of_unit(card)
			if unit_structures.size() > 0:
				play_runway_light(card.Team, card.Position.X)
			for unit in unit_structures:
				unit.Id = id
				create_unit_node(unit, UNIT_LAUNCHING)
				id += 1

func update_ui(game):
	get_node("UI").update_changes(game)

func create_projectile(type, target_id, lifetime, initial_position):
	assert(get_node("Units").has_node(str(target_id)))
	var node = load("res://projectile/" + type + ".tscn").instance()
	var target = get_node("Units").get_node(str(target_id))
	node.initialize(target, lifetime, initial_position)
	get_node("Projectiles").add_child(node)

func play_runway_light(team, pos_x):
	var effect = load("res://effect/runway.tscn").instance()
	var color = "Red"
	var pos = Vector2(global.MAP.width - pos_x, 0 - 10)
	if global.team == team:
		color = "Blue"
		pos = Vector2(pos_x, global.MAP.height + 10)
		effect.set_rot(PI)
	get_node("MothershipBG/%sLight" % color).hide()
	effect.set_pos(pos)
	add_child(effect)
	effect.play()
	yield(effect, "finished")
	effect.queue_free()
	get_node("MothershipBG/%sLight" % color).show()