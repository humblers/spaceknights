extends Node

const OBJECT_DEFAULT = "default"
const OBJECT_CLIENT_ONLY = "clientonly"

func _ready():
	get_node("MothershipBG/BlueBaseBottom")
	get_node("OpeningAnim").connect("finished", self, "opening_finished")
	get_node("MothershipBG/RedLight").set_z(global.LAYERS.MothershipOver)
	get_node("MothershipBG/BlueLight").set_z(global.LAYERS.MothershipOver)
	tcp.connect("packet_received", self, "update_changes")

func update_changes(game):
	global.team = "Home" if game.has("Home") else "Visitor"
	create_new_units(game.Units)
	update_units(game)
	delete_dead_units(game.Units)
	create_new_spells(game.Spells)
	delete_finished_spells(game.Spells)
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
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			continue
		if not has_id(units, node.get_name()):
			var effect = resource.effect.explosion.unit.instance()
			effect.initialize(global.dict_get(global.UNITS[node.name], "size", "small"), node.get_pos())
			add_child(effect)
			node.queue_free()

func create_new_units(units):
	for unit in units:
		if not get_node("Units").has_node(str(unit.Id)):
			create_unit_node(unit)

func update_units(game):
	var units = game.Units
	for unit in units:
		var node = get_node("Units").get_node(str(unit.Id))
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			node.remove_from_group(OBJECT_CLIENT_ONLY)
		if node.color == "blue" and global.is_knight(unit.Name):
			node.set_ignore_server(
					game[global.team][global.id].KnightIdleTo < game.Frame)
		node.update_changes(unit)

func create_unit_node(unit, group=OBJECT_DEFAULT):
	var name = unit.Name
	var node = resource.unit[name].instance()
	node.initialize(unit)
	node.set_name(str(unit.Id))
	node.connect("projectile_created", self, "create_projectile")
	get_node("Units").add_child(node)
	if group == OBJECT_CLIENT_ONLY:
		node.set_launch_effect(unit)
		node.add_to_group(group)
	if node.color == "blue" and global.is_knight(unit.Name):
		node.connect("position_changed", get_node("UI"), "update_knight_position")
		get_node("UI").knight_pos = node.get_pos()

func create_new_spells(spells):
	for id in spells:
		if not get_node("Spells").has_node(id):
			var spell = spells[id]
			spell.Id = id
			create_spell_node(spell)
		var node = get_node("Spells").get_node(id)
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			node.remove_from_group(OBJECT_CLIENT_ONLY)

func delete_finished_spells(spells):
	for node in get_node("Spells").get_children():
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			continue
		if not spells.has(node.get_name()):
			node.queue_free()

func create_spell_node(spell, group=OBJECT_DEFAULT):
	var name = spell.Name
	var node = resource.spell[name].instance()
	node.initialize(spell)
	node.set_name(str(spell.Id))
	var knight = global.knights[str(spell.Knight.Id)]
	knight.connect("position_changed", node, "update_position")
	get_node("Spells").add_child(node)
	if group != OBJECT_DEFAULT:
		node.add_to_group(group)

func handle_waiting_cards(frame, cards):
	for card in cards:
		if frame + global.CARD_WAIT_FRAME != card.ActivateFrame:
			continue
		if global.is_unit_card(card.Name):
			var unit_structures = global.get_structures_of_unit(card)
			if unit_structures.size() > 0:
				play_runway_light(card.Team, card.Position.X)
			var id = card.IdStarting
			for unit in unit_structures:
				unit.Id = id
				create_unit_node(unit, OBJECT_CLIENT_ONLY)
				id += 1
		if global.is_spell_card(card.Name):
			card.Id = card.IdStarting
			create_spell_node(card, OBJECT_CLIENT_ONLY)

func update_ui(game):
	get_node("UI").update_changes(game)

func create_projectile(type, target, lifetime, initial_position):
	var target_type = typeof(target)
	var proj_node = resource.projectile[type].instance()
	if target_type in [TYPE_INT, TYPE_REAL, TYPE_STRING]:
		var target_node = get_node("Units").get_node(str(target))
		proj_node.set_single_target(target_node, lifetime, initial_position)
	elif target_type in [TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY]:
		var target_nodes = []
		for id in target:
			target_nodes.append(get_node("Units").get_node(str(id)))
		proj_node.set_multi_target(target_nodes, lifetime, initial_position)
	else:
		print("unknown target type(%d)" % target_type)
		return
	get_node("Projectiles").add_child(proj_node)

func play_runway_light(team, pos_x):
	var effect = resource.effect.runway.instance()
	var color = "Red"
	var pos = Vector2(pos_x, -10)
	if global.team == team:
		color = "Blue"
		pos.y = global.MAP.height - pos.y
		effect.set_rot(PI)
	if global.team == "Visitor":
		pos.x = global.MAP.width - pos.x
	get_node("MothershipBG/%sLight" % color).hide()
	effect.set_pos(pos)
	add_child(effect)
	effect.play()
	yield(effect, "finished")
	effect.queue_free()
	get_node("MothershipBG/%sLight" % color).show()