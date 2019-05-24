extends Control

export(NodePath) onready var tile = get_node(tile)
export(NodePath) onready var map = get_node(map)
export(NodePath) onready var knight_button_left = get_node(knight_button_left)
export(NodePath) onready var knight_button_right = get_node(knight_button_right)

export(NodePath) onready var knight_guide = get_node(knight_guide)
export(NodePath) onready var squire_guide = get_node(squire_guide)

onready var icon = $Card/ItemBase/Control/Icon
onready var cost_label = $Card/ItemBase/Control/Cost/Label
onready var cost_icon = $Card/ItemBase/Control/Cost
onready var energy_bar = $Card/Energy
onready var glow = $Card/Glow

onready var card_init_pos = $Card.position
onready var card_init_scale = $Card.scale
onready var card_init_z_index = $Card.z_index
onready var cursor_init_pos = $Cursor.position
onready var dummy_init_pos = $Rotate/Dummy.position

export(int, 1, 4)  var index = null

var game
var player
var card
var pressed = false
var input_sent = false

var knight = null
var focused = false
var guide
var prev_mouse = null

func _ready():
	connect("gui_input", self, "handle_input")
	knight_button_left.connect("gui_input", self, "handle_knight_input", ["Left"])
	knight_button_right.connect("gui_input", self, "handle_knight_input", ["Right"])
	map.connect("gui_input", self, "handle_map_input")
	event.connect("GameInitialized", self, "setGame", [], CONNECT_ONESHOT)
	event.connect("BluePlayerInitialized", self, "setPlayer", [], CONNECT_ONESHOT)
	event.connect("BlueEnergyUpdated", self, "updateEnergy")
	event.connect("BlueSetHand%d" % index, self, "setHand")
	event.connect("BlueHandFocused", self, "updateFocus")

func setGame(game):
	self.game = game

func setPlayer(player):
	self.player = player

func handle_knight_input(event, side):
	if card and card.Side == side:
		event.position = get_local_mouse_position()
		handle_input(event, side)
		
func handle_map_input(ev):
	if input_sent or not focused:
		return
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			pass
		else:
			map_on_released(ev)
	if ev is InputEventMouseMotion and pressed:
		pass
		

func setHand(card):
	if card == null:
		visible = false		# also cancels previous input
		pressed = false
		input_sent = false
	else:
		visible = true
		self.card = card
		$AnimationPlayer.stop()
		tile.Hide()
		init_card(card)
		init_cursor(card)
		init_dummy(card)
		if card.Type == data.KnightCard:
			event.emit_signal("BlueMothershipDeckUpdate", event.MothershipDeckOpen, card.Side)

func updateEnergy(energy):
	if input_sent:
		return
	var ready = energy >= energy_bar.max_value
	cost_icon.playing = ready
	glow.visible = ready
	energy_bar.value = card.Cost - energy
	if card.Type == data.KnightCard:
		var ratio = float(energy)/card.Cost
		event.emit_signal("BlueMothershipDeckUpdate", event.MothershipDeckCharging, card.Side, ratio)

func init_card(card = null):
	$Card.position = card_init_pos
	$Card.scale = card_init_scale
	$Card.z_index = card_init_z_index
	if card != null:
		var path = loading_screen.GetCardIconPathInGame(card.Name)
		icon.texture = loading_screen.LoadResource(path)
		cost_label.text = str(card.Cost/1000)
		energy_bar.max_value = card.Cost
		
		if card.Type == data.KnightCard:
			guide = knight_guide
		else:
			guide = squire_guide
	
func init_cursor(card = null):
	$Cursor.visible = false
	guide.visible = false
	$Cursor.position = cursor_init_pos
	if card != null:
		for c in $Cursor.get_children():
			c.queue_free()
		var cursor_path = loading_screen.GetCursorScenePath(card)
		var cursor_node = loading_screen.LoadResource(cursor_path).instance()
		if card.Type == data.SquireCard:
			for i in card.Count:
				var path = loading_screen.GetUnitScenePath(card.Unit)
				var unit_node = loading_screen.LoadResource(path).instance()
				unit_node.position = Vector2(card.OffsetX[i], card.OffsetY[i])
				unit_node.modulate = Color(1, 1, 1, 0.5)
				$Cursor.add_child(unit_node)
			# TODO: change data.Squire to data.SquireCard
			$Cursor.add_child(cursor_node)
			cursor_node.set_text(card.Name, card.Level+data.Upgrade.dict.RelativeLvByRarity[card.Rarity])
		else:
			$Cursor.add_child(cursor_node)
			cursor_node.set_level(card.Level+data.Upgrade.dict.RelativeLvByRarity[card.Rarity])

func init_dummy(card):
	$Rotate/Dummy.position = dummy_init_pos
	for c in $Rotate/Dummy.get_children():
		c.queue_free()
	if card.Type == data.SquireCard:
		for i in card.Count:
			var path = loading_screen.GetUnitScenePath(card.Unit)
			var node = loading_screen.LoadResource(path).instance()
			node.position = Vector2(card.OffsetX[i], card.OffsetY[i])
			$Rotate/Dummy.add_child(node)
	
func handle_input(ev, side = null):
	if input_sent:
		return
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			on_pressed(side)
		else:
			on_released(side)
	if ev is InputEventMouseMotion and pressed:
		on_dragged(ev)

func on_pressed(side = null):
	tile.Show(data.CardIsSpell(card))
	$Card.z_index += 1
	event.emit_signal("BlueHandFocused", index)
	prev_mouse = "Pressed"

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
		set_guide_pos(int(pos.x), int(pos.y))
		guide.visible = true
		
	else:
		$Cursor.visible = false
		guide.visible = false
	
	prev_mouse = "Dragged"
	
func map_on_released(ev):
	$Card.position = ev.position
	
	var y = ev.position.y
	
	var pos = map.get_local_mouse_position()
	set_cursor_pos(int(pos.x), int(pos.y))
	$Cursor.visible = true
	set_guide_pos(int(pos.x), int(pos.y))
	guide.visible = true
	on_released()


func on_released(side = null):
	pressed = false
	if not focused:
		tile.Hide()
	
	var pos = map.get_local_mouse_position()
		
	if side and pos.y < map.rect_size.y:
		if prev_mouse != "Dragged":
			return
		elif knight.get_node("AnimationPlayer").get_current_animation() == "skill_ready":
			return
		
	if card.Type == data.KnightCard and knight:
		knight.set_rotation_degrees(0)
	
	# released on map?
	
	if pos.y > map.rect_size.y:
		init_card()
		init_cursor()
		if prev_mouse == "Dragged":
			focused = false
			guide.visible = false
			tile.Hide()
			knight_button_left.visible = true
			knight_button_right.visible = true
			if knight != null:
				knight.skillRest()
		prev_mouse = "Released"
		rotateRunway(0)
		return
	
	# enough energy?
	if $Card/Energy.value > 0:
		show_message("ID_ERROR_ENERGY", pos.y) 
		init_card()
		init_cursor()
		prev_mouse = "Released"
		rotateRunway(0)
		return
	
	# send input
	player.send_input(card, $Cursor.global_position - map.rect_position)
	input_sent = true

	# play launch and show anim
	if card.Type == data.SquireCard:
		$AnimationPlayer.play("launch")
		yield($AnimationPlayer, "animation_finished")
		$Rotate/Dummy.position = $Cursor.position
		$Cursor.visible = false
		guide.visible = false
		self.get_node("Rotate").set_rotation_degrees(0)
		var offsetpos = self.get_node("Rotate/Dummy").position
		offsetpos += Vector2(-95, -65)
		self.get_node("Rotate/Dummy").set_position(offsetpos)
		$AnimationPlayer.play("show")
		yield($AnimationPlayer, "animation_finished")
		rotateRunway(0)

	if card.Type == data.KnightCard:
		event.emit_signal("BlueMothershipDeckUpdate", event.MothershipDeckClose, card.Side)
		guide.visible = false
		
	knight_button_left.visible = true
	knight_button_right.visible = true
	prev_mouse = "Released"
	focused = false
	tile.Hide()

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
	var isSpell = data.CardIsSpell(card)
	if not isSpell:
		tile = player.ClampToValidTile(tile[0], tile[1])
		var num = data.CardTileNum(card)
		var nx = num[0]
		var ny = num[1]
		var tr = game.NewTileRect(tile[0], tile[1], nx, ny)
		tr = player.FindUnoccupiedTileRect(tr, 5)
		if tr == null:
			print("cannot find unoccupied tile")
			return
		tile[0] = tr.x
		tile[1] = tr.y

	var pos = game.PosFromTile(tile[0], tile[1])
	if game.team_swapped:
		pos[0] = game.FlipX(pos[0])
		pos[1] = game.FlipY(pos[1])
	$Cursor.global_position.x = pos[0] + map.rect_position.x
	$Cursor.global_position.y = pos[1] + map.rect_position.y

func set_guide_pos(x, y):
	if game.team_swapped:
		x = game.FlipX(x)
		y = game.FlipY(y)

	var tile = game.TileFromPos(x, y)
	var isSpell = data.CardIsSpell(card)
	if not isSpell:
		tile = player.ClampToValidTile(tile[0], tile[1])
		var num = data.CardTileNum(card)
		var nx = num[0]
		var ny = num[1]
		var tr = game.NewTileRect(tile[0], tile[1], nx, ny)
		tr = player.FindUnoccupiedTileRect(tr, 5)
		if tr == null:
			print("cannot find unoccupied tile")
			return
		tile[0] = tr.x
		tile[1] = tr.y

	var pos = game.PosFromTile(tile[0], tile[1])
	if game.team_swapped:
		pos[0] = game.FlipX(pos[0])
		pos[1] = game.FlipY(pos[1])

	var from
	var target = Vector2(pos[0] + map.rect_position.x, pos[1] + map.rect_position.y)

	if card.Type == data.SquireCard:
		from = Vector2( (int(self.name.right(4)) -1) * 202 + 346, 1800)
		guide.set_position(from)

	else:
		from = Vector2(player.INITIAL_KNIGHT_POSITION_X[card.Side] + map.rect_position.x ,player.INITIAL_KNIGHT_POSITION_Y[card.Side] + map.rect_position.y)
		guide.set_position(from)
	
	var dir = from-target
	var ref = Vector2(0,100)
	var angle = ref.angle_to(dir)
	
	#skill.look_at(vec.rotated(PI / 2))
	guide.set_rotation_degrees((180/PI) * angle)
	guide.get_node("Sprite").value = (dir.length()/15.3)

	if card.Type == data.KnightCard:
		if !knight.get_node("AnimationPlayer").get_current_animation():
			#knight.set_rotation_degrees((180/PI) * angle)
			pass
	else:
		rotateRunway(angle)
		self.get_node("Rotate").set_rotation_degrees((180/PI) * angle)

func updateFocus(focused_hand_index):
	focused = index == focused_hand_index
	if focused:
		$AnimationPlayer.play("card%d_ready" % index)
		var knight_btns = [knight_button_left, knight_button_right]
		if card.Type == data.KnightCard:
			knight_btns.erase(knight_button_left if card.Side == data.Left else knight_button_right)
		for btn in knight_btns:
			btn.visible = false
		knight = player.findKnight(card.Name)
	else:
		$AnimationPlayer.play("card%d_rest" % index)

func rotateRunway(angle):
	var runway
	event.emit_signal("RunwayRotate", int(self.name[4]), (180/PI) * angle)