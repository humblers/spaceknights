extends Control

onready var game = get_node("../../")
onready var player = get_node("../../Players/Blue")
onready var tile = get_node("../Tile")
onready var map = get_node("../Map")
onready var map_bottom = map.rect_position.y + map.rect_size.y
onready var unit_resource = get_node("../../Resource/Unit")
onready var icon_resource = get_node("../../Resource/Icon")
onready var dummy_init_pos = $Dummy.position

export(int) var index
var card_name
var card_level
var init_pos
var init_scale
var init_z_index
var pressed = false

func is_knight_card(name):
	var card = stat.cards[name]
	var unit = stat.units[card.Unit]
	return unit.type == "Knight"
	
func _ready():
	connect("gui_input", self, "handle_input")

func _process(delta):
	var name = player.hand[index].Name
	var level = player.hand[index].Level
	if name == null or name == "":
		return
	if is_knight_card(name):
		$Card.visible = true
		$Cursor.visible = false
		$Card/Icon.visible = false
		$Card/NotAvailable.visible = true
		$Card/Energy.value = 0
		return
	if card_name == null or card_name != name:
		card_name = name
		card_level = level
		clear_units()
		add_units()
		var cost = stat.cards[card_name].Cost
		$Card.visible = true
		$Card/Icon.visible = true
		$Card/NotAvailable.visible = false
		$Card/Icon.texture = icon_resource.get_resource(card_name)
		$Card/Icon/Energy/Cost.text = str(cost/1000)
		$Card/Energy.max_value = cost

	# update energy
	var cost = stat.cards[card_name].Cost
	var ready = player.energy >= cost
	$Card/Icon/NotReady.visible = not ready
	$Card/Icon/Ready.visible = ready
	$Card/Energy.value = player.energy
	$Card/Icon/Energy.playing = ready

func handle_input(ev):
	if card_name == null:
		return
	if is_knight_card(card_name):
		return
	if ev is InputEventMouseMotion and pressed:
		on_dragged(ev)
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			on_pressed()
		else:
			on_released(ev)

func on_pressed():
	init_pos = $Card.position
	init_scale = $Card.scale
	init_z_index = $Card.z_index
	$Card.z_index += 1
	tile.ShowArea(true)
	
func on_released(ev):
	tile.Hide()
	$Card.position = init_pos
	$Card.scale = Vector2(1, 1)
	$Card.z_index = init_z_index
	$Cursor.visible = false

	# released on map?
	var pos = map.get_local_mouse_position()
	if pos.y > map.rect_size.y:
		return
	
	if player.energy < stat.cards[card_name]["Cost"]:
		show_message("Not Enought Energy", pos.y)
		return

	$Cursor.visible = true
	$Card.visible = false
	send_input(pos)
	$AnimationPlayer.play("launch")
	yield($AnimationPlayer, "animation_finished")
	$Dummy.position = $Cursor.position
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	$Dummy.position = dummy_init_pos
	$Dummy.visible = false

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
					"Name": card_name,
					"Level": card_level,
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

func set_cursor_pos(x, y):
	var card = stat.cards[card_name]
	var unit = stat.units[card.Unit]
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

func add_units():
	var card = stat.cards[card_name]
	var unit = card["Unit"]
	var count = card["Count"]
	var offsetX = card["OffsetX"]
	var offsetY = card["OffsetY"]
	for i in count:
		var node = unit_resource.get_resource(unit).instance()
		node.position = Vector2(offsetX[i], offsetY[i])
		$Dummy.add_child(node)
		$Dummy.visible = true
		node = node.duplicate()
		node.modulate = Color(1.0, 1.0, 1.0, 0.5)
		$Cursor.add_child(node)
		$Cursor.visible = false

func clear_units():
	for c in $Dummy.get_children():
		c.queue_free()
	for c in $Cursor.get_children():
		c.queue_free()

func show_message(msg, pos_y):
	var message_bar = map.get_node("Message")
	var tween = message_bar.get_node("Tween")
	var pos_x = message_bar.rect_position.x
	message_bar.text = msg
	tween.interpolate_property(message_bar, "rect_position", Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 40), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(message_bar, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
