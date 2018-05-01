extends Node

const OBJECT_DEFAULT = "default"
const OBJECT_CLIENT_ONLY = "clientonly"

func _ready():
	self.offset.x = get_camera_x_offset()
	get_node("UI").connect_ui_signals()
	tcp.connect("packet_received", self, "update_changes")

func update_changes(game):
	if debug.size_changed:
		debug.size_changed = false
		self.offset.x = get_camera_x_offset()
	global.team = game.Players[global.id].Team
	create_new_units(game.Units)
	update_units(game.Units)
	delete_dead_units(game.Units)
	create_new_spells(game.Spells)
	delete_finished_spells(game.Spells)
	handle_waiting_cards(game.Frame, global.dict_get(game, "WaitingCards", []))
	update_ui(game)

func delete_dead_units(units):
	var nodes = get_node("red/Units").get_children() + get_node("blue/Units").get_children()
	for node in nodes:
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			continue
		if not units.has(node.get_name()):
			var effect = resource.effect.explosion.unit.instance()
			effect.initialize(global.dict_get(global.UNITS[node.u_name], "size", "small"), node.position)
			add_child(effect)
			node.queue_free()

func create_new_units(units):
	for id in units:
		var unit = units[id]
		if not get_node("red/Units").has_node(id) and not get_node("blue/Units").has_node(id):
			create_unit_node(unit)

func update_units(units):
	for id in units:
		var unit = units[id]
		var node = get_unit_node(id)
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			node.remove_from_group(OBJECT_CLIENT_ONLY)
		node.update_changes(unit)

func create_unit_node(unit, group=OBJECT_DEFAULT):
	var name = unit.Name
	var node = resource.unit[name].instance()
	node.initialize(unit)
	node.set_name(str(unit.Id))
	node.connect("projectile_created", self, "create_projectile")
	get_node("%s/Units" % node.color).add_child(node)
	if group == OBJECT_CLIENT_ONLY:
		node.set_launch_effect(unit)
		node.add_to_group(group)

func create_new_spells(spells):
	for id in spells:
		if not get_node("Spells").has_node(id):
			var spell = spells[id]
			spell.Id = id
			create_spell_node(spell)
		var node = get_node("Spells").get_node(id)
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			node.remove_from_group(OBJECT_CLIENT_ONLY)
			node.play("active")

func delete_finished_spells(spells):
	for node in get_node("Spells").get_children():
		if node.is_in_group(OBJECT_CLIENT_ONLY):
			continue
		if not spells.has(node.get_name()):
			node.release()

func create_spell_node(spell, group=OBJECT_DEFAULT):
	var name = spell.Name
	var node = resource.spell[name].instance()
	node.initialize(spell)
	node.set_name(str(spell.Id))
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
	var projectiles = get_node("Projectiles")
	#initial_position = projectiles.to_local(initial_position)
	var target_type = typeof(target)
	var proj_node = resource.projectile[type].instance()
	if target_type in [TYPE_INT, TYPE_REAL, TYPE_STRING]:
		var target_node = get_unit_node(str(target))
		proj_node.set_single_target(target_node, lifetime, initial_position)
	elif target_type in [TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY]:
		var target_nodes = []
		for id in target:
			target_nodes.append(get_unit_node(str(id)))
		proj_node.set_multi_target(target_nodes, lifetime, initial_position)
	else:
		print("unknown target type(%d)" % target_type)
		return
	projectiles.add_child(proj_node)

func get_unit_node(id):
	if get_node("red/Units").has_node(id):
		return get_node("red/Units").get_node(id)
	if get_node("blue/Units").has_node(id):
		return get_node("blue/Units").get_node(id)
	return null
	
func play_runway_light(team, pos_x):
	var effect = resource.effect.runway.instance()
	var color = "Red"
	var pos = Vector2(pos_x, -10)
	if global.team == team:
		color = "Blue"
		pos.y = global.MAP.height - pos.y
		effect.rotation = PI
	if global.team == "Visitor":
		pos.x = global.MAP.width - pos.x
	
	effect.position = pos
	add_child(effect)
	effect.play()
	yield(effect, "animation_finished")
	effect.queue_free()
	
func get_camera_x_offset():
	var ow = ProjectSettings.get_setting("display/window/size/width")
	var oh = ProjectSettings.get_setting("display/window/size/height")
	var size = get_viewport().size
	var ratio = 1- (size.y * ow / size.x / oh)
	if ratio < 1:
		return -ow * ratio / 2
	return 0