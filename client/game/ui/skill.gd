extends Control

onready var game = get_node("../../")
onready var player = get_node("../../Players/Blue")
onready var tile = get_node("../Tile")
onready var map = get_node("../Map")
onready var cursor_resource = get_node("../../Resource/Cursor")
onready var mothership = get_node("../../MotherShips/Blue")
onready var mothership_anim = get_node("../../MotherShips/Blue/Ship")

export(int, 1, 2) var index
export(String, "Left", "Right") var side

var card_name
var card_level
var pressed = false
var ready_node

func init():
	var knight = game.FindUnit(player.knightIds[index])
	card_name = knight.name_
	card_level = knight.level
	$Cursor.add_child(cursor_resource.get_resource(card_name).instance())
	$Cursor.visible = false
	connect("gui_input", self, "handle_input")
	ready_node = mothership.get_node("Nodes/Deck/%s/Ready%s/SkillReadyC" % [side, side.left(1)])

func is_in_hand():
	for card in player.hand:
		if card.Name == card_name:
			return true
	return false

func _process(delta):
	if mothership_anim.is_playing():
		return
	if len(player.knightIds) <= 0:
		return
	if card_name == null or card_name == "":
		init()
#func _process(delta):
#	if not is_in_hand():
#		mothership_anim.play("default_%s" % side.to_lower())
#		return
#	if 
#	var cost = stat.cards[card_name].Cost
#	var ready = player.energy >= cost
#	if ready:
#		mothership_anim.play("%s_skill_" % side.to_lower())
#	else:
#		pass

func handle_input(ev):
	if ev is InputEventMouseMotion and pressed:
		on_dragged(ev)
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			on_pressed()
		else:
			on_released(ev)

func on_pressed():
	tile.ShowArea(false)
	$Cursor.visible = true
	
func on_released(ev):
	tile.Hide()
	$Cursor.visible = false

	# released on map?
	var pos = map.get_local_mouse_position()
	if pos.y > map.rect_size.y:
		return

	# check energy
	if player.energy < stat.cards[card_name]["Cost"]:
		show_message("Not Enought Energy", pos.y)

	send_input(pos)

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
	var pos = map.get_local_mouse_position()
	set_cursor_pos(int(pos.x), int(pos.y))

func set_cursor_pos(x, y):
	var card = stat.cards[card_name]
	var unit = stat.units[card.Unit]
	var tile = game.TileFromPos(x, y)
	if unit.skill.wing.has("unit"):
		var nx = 1
		var ny = 1
		var minTileY = game.Map().MinTileYOnBot()
		var maxTileY = game.Map().TileNumY() - 1
		if unit and unit["type"] == "Building":
			nx = unit["tilenumx"]
			ny = unit["tilenumy"]
		tile[1] = int(clamp(tile[1], minTileY, maxTileY))
		var res = avoid_occupied_tiles(tile[0], tile[1], nx, ny, minTileY, maxTileY)
		if res[1] == null:
			var tr = res[0]
			tile[0] = (tr.l + tr.r) / 2
			tile[1] = (tr.t + tr.b) / 2
		else:
			print(res[1]) # error
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

func show_message(msg, pos_y):
	var message_bar = map.get_node("Message")
	var tween = message_bar.get_node("Tween")
	var pos_x = message_bar.rect_position.x
	message_bar.text = msg
	tween.interpolate_property(message_bar, "rect_position", Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 40), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(message_bar, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
