extends Control

export(NodePath) onready var game = get_node(game)
export(NodePath) onready var player = get_node(player)
export(NodePath) onready var tile = get_node(tile)
export(NodePath) onready var map = get_node(map)
export(NodePath) onready var unit_resource = get_node(unit_resource)
export(NodePath) onready var cursor_resource = get_node(cursor_resource)
export(NodePath) onready var icon_resource = get_node(icon_resource)

onready var card_init_pos = $Card.position
onready var card_init_scale = $Card.scale
onready var card_init_z_index = $Card.z_index
onready var cursor_init_pos = $Cursor.position
onready var dummy_init_pos = $Dummy.position

var card
var pressed = false

func Set(card):
	if card == null:
		visible = false
		return
	else:
		visible = true
	self.card = card
	clear_cursor_and_dummy()
	add_cursor_and_dummy(card)
	$Card/Icon.texture = icon_resource.get_resource(card.Name)
	$Card/Cost/Label.text = str(card.Cost/1000)
	$Card/Energy.max_value = card.Cost
	init()

func Update(energy):
	var ready = energy >= $Card/Energy.max_value
	$Card/Icon/NotReady.visible = not ready
	$Card/Icon/Ready.visible = ready
	$Card/Cost.playing = ready
	$Card/Energy.value = energy

func init():
	$Card.visible = true
	$Card.position = card_init_pos
	$Card.scale = card_init_scale
	$Card.z_index = card_init_z_index
	$Cursor.visible = false
	$Cursor.position = cursor_init_pos
	$Dummy.position = dummy_init_pos
	$AnimationPlayer.stop()
	if not is_connected("gui_input", self, "handle_input"):
		connect("gui_input", self, "handle_input")

func add_cursor_and_dummy(card):
	if card.Type == stat.SquireCard:
		for i in card.Count:
			var node = unit_resource.get_resource(card.Unit).instance()
			node.position = Vector2(card.OffsetX[i], card.OffsetY[i])
			$Dummy.add_child(node)
			node = node.duplicate()
			node.modulate = Color(1, 1, 1, 0.5)
			$Cursor.add_child(node)
		# TODO: change stat.Squire to stat.SquireCard
		var node = cursor_resource.get_resource(stat.Squire.to_lower()).instance()
		$Cursor.add_child(node)
	else:
		var node = cursor_resource.get_resource(card.Name).instance()
		$Cursor.add_child(node)

func clear_cursor_and_dummy():
	for c in $Cursor.get_children():
		c.queue_free()
	for c in $Dummy.get_children():
		c.queue_free()

func handle_input(ev):
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			on_pressed()
		else:
			on_released(ev)
	if ev is InputEventMouseMotion and pressed:
		on_dragged(ev)

func on_pressed():
	var is_unit = true
	if card.Type == stat.KnightCard:
		var skill = stat.units[card.Name].skill.wing
		if not skill.has("unit"):
			is_unit = false
		else:
			if stat.units[skill.unit].type != stat.Building:
				is_unit = false
	tile.Show(can_use_anywhere())
	$Card.z_index += 1

func can_use_anywhere():
	if card.Type == stat.KnightCard:
		var skill = stat.units[card.Name].skill.wing
		if not skill.has("unit"):
			return true
		else:
			if stat.units[skill.unit].type != stat.Building:
				return true
	return false

func on_dragged(ev):
	$Card.position = ev.position
	
	# scale
	var y = ev.position.y
	var bottom = map.rect_position.y + map.rect_size.y
	var dist = rect_position.y - bottom
	if y < 0:
		var ratio = abs(y) / dist
		var s = lerp(1, 0, clamp(ratio, 0, 1))
		$Card.scale = Vector2(s, s)
	
	# set cursor
	if y < -dist:
		var pos = map.get_local_mouse_position()
		set_cursor_pos(int(pos.x), int(pos.y))
		$Cursor.visible = true
	else:
		$Cursor.visible = false
	
func on_released(ev):
	tile.Hide()
	
	# released on map?
	var pos = map.get_local_mouse_position()
	if pos.y > map.rect_size.y:
		init()
		return
	
	# enough energy?
	if $Card/Energy.value < $Card/Energy.max_value:
		show_message("Not Enough energy", pos.y)
		init()
		return
	
	player.send_input(card, $Cursor.global_position - map.rect_position)
	$Card.visible = false
	disconnect("gui_input", self, "handle_input")
	$AnimationPlayer.play("launch")
	yield($AnimationPlayer, "animation_finished")
	$Dummy.position = $Cursor.position
	$Cursor.visible = false
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")

func show_message(msg, pos_y):
	var message_bar = map.get_node("Message")
	var tween = message_bar.get_node("Tween")
	var pos_x = message_bar.rect_position.x
	message_bar.text = msg
	tween.interpolate_property(message_bar, "rect_position", Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 40), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(message_bar, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func set_cursor_pos(x, y):
	if game.team_swapped:
		x = game.FlipX(x)
		y = game.FlipY(y)
	var tile = game.TileFromPos(x, y)
	if not can_use_anywhere():
		var minY = 0
		var maxY = game.Map().TileNumY() - 1
		if player.team == "Blue":
			minY = game.Map().MinTileYOnBot()
		else:
			maxY = game.Map().MaxTileYOnTop()
		tile[1] = int(clamp(tile[1], minY, maxY))
		var nx = 1
		var ny = 1
		if card.Type == stat.KnightCard:
			var skill = stat.units[card.Unit].skill.wing
			if skill.has("unit"):
				var unit = stat.units[skill.unit]
				if unit.type == stat.Building:
					nx = unit.tilenumx
					ny = unit.tilenumy
		var res = avoid_occupied_tiles(tile[0], tile[1], nx, ny, minY, maxY)
		if res[1] == null:
			var tr = res[0]
			tile[0] = (tr.l + tr.r) / 2
			tile[1] = (tr.t + tr.b) / 2
		else:
			print(res[1])	# error
	if game.team_swapped:
		tile[0] = game.FlipX(tile[0])
		tile[1] = game.FlipY(tile[1])
	var pos = game.PosFromTile(tile[0], tile[1])
	$Cursor.global_position.x = pos[0] + map.rect_position.x
	$Cursor.global_position.y = pos[1] + map.rect_position.y

func avoid_occupied_tiles(x, y, w, h, minY, maxY, counter=0):
	if counter >= game.Map().TileNumY() - 1:
		return [null, "can't placed"]
	var shifted = []
	for i in range(x - counter, x + counter + 1):
		for j in range(y - counter, y + counter + 1):
			var tr = {"t":j-h/2, "b":j+h/2, "l":i-w/2, "r":i+w/2}
			if tr.t < minY || tr.b > maxY:
				continue
			if tr.l < 0 || tr.r > game.Map().TileNumX() - 1:
				continue
			var intersect = false
			for occupied in game.OccupiedTiles().keys():
				if game.intersect_tilerect(occupied, tr):
					intersect = true
					break
			if not intersect:
				return [tr, null]
	return avoid_occupied_tiles(x, y, w, h, minY, maxY, counter + 1)