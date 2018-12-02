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
	tile.Show(is_unit)
	$Card.z_index += 1

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
	
	send_input($Cursor.global_position - map.rect_position)
	$Card.visible = false
	disconnect("gui_input", self, "handle_input")
	$AnimationPlayer.play("launch")
	yield($AnimationPlayer, "animation_finished")
	$Dummy.position = $Cursor.position
	$Cursor.visible = false
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")

func send_input(pos):
	var x = int(pos.x)
	var y = int(pos.y)
	if game.team_swapped:
		x = game.FlipX(x)
		y = game.FlipY(y)
	var tile = game.TileFromPos(x, y)
	var input = {
			"Step": game.step + player.INPUT_DELAY_STEP,
			"Action": {
				"Id": player.id,
				"Card": {
					"Name": card.Name,
					"Level": card.Level,
				},
				"TileX": tile[0],
				"TileY": tile[1],
			},
	}
	if game.connected:
		tcp.Send(input)
	else:
		if game.actions.has(input.Step):
			game.actions[input.Step].append(input.Action)
		else:
			game.actions[input.Step] = [input.Action]

func show_message(msg, pos_y):
	var message_bar = map.get_node("Message")
	var tween = message_bar.get_node("Tween")
	var pos_x = message_bar.rect_position.x
	message_bar.text = msg
	tween.interpolate_property(message_bar, "rect_position", Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 40), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(message_bar, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func set_cursor_pos(x, y):
	var tile = game.TileFromPos(x, y)
	var minTileY = game.Map().MinTileYOnBot()
	var maxTileY = game.Map().TileNumY() - 1
	tile[1] = int(clamp(tile[1], minTileY, maxTileY))
	var res = avoid_occupied_tiles(tile[0], tile[1], 1, 1, minTileY, maxTileY)
	if res[1] == null:
		var tr = res[0]
		tile[0] = (tr.l + tr.r) / 2
		tile[1] = (tr.t + tr.b) / 2
	else:
		print(res[1])	# error
	var pos = game.PosFromTile(tile[0], tile[1])
	$Cursor.global_position.x = pos[0] + map.rect_position.x
	$Cursor.global_position.y = pos[1] + map.rect_position.y

func avoid_occupied_tiles(x, y, w, h, minTop, maxBot, counter=0):
	var shifted = []
	# left
	if x-w/2-counter >= 0:
		shifted.append({"t":y-h/2, "b":y+h/2, "l":x-w/2-counter, "r":x+w/2-counter})
	# right
	if x+w/2+counter <= game.Map().TileNumX() - 1:
		shifted.append({"t":y-h/2, "b":y+h/2, "l":x-w/2+counter, "r":x+w/2+counter})
	# bottom
	if y+h/2+counter <= maxBot:
		shifted.append({"t":y-h/2+counter, "b":y+h/2+counter, "l":x-w/2, "r":x+w/2})
	# top
	if y-h/2-counter >= minTop:
		shifted.append({"t":y-h/2-counter, "b":y+h/2-counter, "l":x-w/2, "r":x+w/2})
	var candidates = []
	for tr in shifted:
		if tr.t < minTop || tr.b > maxBot || tr.l < 0 || tr.r > game.Map().TileNumX() - 1:
			continue
		candidates.append(tr)
	if len(candidates) == 0:
		return [null, "can't placed"]
	for tr in candidates:
		var intersect = false
		for occupied in game.OccupiedTiles().keys():
			if game.intersect_tilerect(occupied, tr):
				intersect = true
				break
		if not intersect:
			return [tr, null]
	counter += 1
	return avoid_occupied_tiles(x, y, w, h, minTop, maxBot, counter)