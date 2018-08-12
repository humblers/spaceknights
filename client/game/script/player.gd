extends VBoxContainer

const MAX_ENERGY = 10000
const START_ENERGY = 7000
const ENERGY_PER_FRAME = 40
const HAND_SIZE = 4

const KNIGHT_INITIAL_POSX = [200, 500, 800]
const KNIGHT_INITIAL_POSY = [1600, 1600, 1600]

const INPUT_DELAY_STEP = 10

var id
var team
var energy = 0
var hand = []
var pending = []
var knightIds = []
var no_deck = false

var game

var selected_card = null
var pressed = false
var action_markers = {}

func Init(playerData, game):
	id = playerData.Id
	team = playerData.Team
	if playerData.has("Deck"):
		energy = START_ENERGY
		for i in range(len(playerData.Deck)):
			var card = playerData.Deck[i]
			if i < HAND_SIZE:
				hand.append(card)
			else:
				pending.append(card)
	else:
		no_deck = true
	self.game = game
	for i in range(len(playerData.Knights)):
		var k = playerData.Knights[i]
		var x = KNIGHT_INITIAL_POSX[i]
		var y = KNIGHT_INITIAL_POSY[i]
		if team == "Red":
			x = game.FlipX(x)
			y = game.FlipY(y)
		var id = game.AddUnit(k.Name, k.Level, x, y, self)
		knightIds.append(id)

	$Energy.max_value = MAX_ENERGY
	$Energy.value = energy
	connect_input()
	if not no_deck:
		update_cards()

func connect_input():
	get_node("../../BattleField").connect("gui_input", self, "gui_input")
	for i in range(HAND_SIZE):
		var button = $Cards.get_node("Card%s/Button" % (i+1))
		button.connect("gui_input", self, "button_input", [i])

func gui_input(ev):
	var field = get_node("../../BattleField")
	var pos = field.get_local_mouse_position()
	var belowField = pos.y > field.get_rect().end.y - field.rect_position.y
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if belowField:
			clear_cursor()
			return
		if not pressed:
			if selected_card == null:
				show_message("No Selected Card", pos.y)
				return
			if energy < stat.cards[selected_card.Name]["cost"]:
				show_message("Not Enought Energy", pos.y)
				clear_cursor()
				return
			var pos_node = get_node("../../BattleField/CursorPos").position
			var x = int(pos_node.x)
			var y = int(pos_node.y)
			if game.team_swapped:
				x = game.FlipX(x)
				y = game.FlipY(y)
			var tile = game.TileFromPos(x, y)
			var input = {
					"Step": game.step + INPUT_DELAY_STEP,
					"Action": {
						"Id": id,
						"Card": {
							"Name": selected_card.Name,
							"Level": selected_card.Level,
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
			mark_action(input)
	if belowField:
		clear_cursor()
		return
	update_cursor(int(pos.x), int(pos.y))

func button_input(ev, i):
	if ev is InputEventMouseButton and ev.pressed:
		selected_card = hand[i]
		if stat.cards[selected_card.Name].has("unit"):
			var redArea = get_node("../../Map/RedArea")
			$Tween.interpolate_property(redArea, "modulate", Color(1.0, 0, 0, 0.0), Color(1.0, 0, 0, 0.3), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
	gui_input(ev)

func add_cursor():
	var pos_node = get_node("../../BattleField/CursorPos")
	var cardData = stat.cards[selected_card.Name]
	var cursor
	if not cardData.has("unit"):
		var k = findKnight(cardData["caster"])
		cursor = resource.CURSOR[k.Name()]
	else:
		cursor = resource.CURSOR["unit"]
		var name = cardData["unit"]
		var count = cardData["count"]
		var offsetX = cardData["offsetX"]
		var offsetY = cardData["offsetY"]
		for i in range(count):
			pos_node.add_child(get_unit(name, offsetX[i], offsetY[i]))
	cursor = cursor.instance()
	pos_node.add_child(cursor)
	pos_node.move_child(cursor, 0)

func update_cursor(x, y):
	if selected_card == null:
		return
	var pos_node = get_node("../../BattleField/CursorPos")
	if pos_node.get_child_count() <= 0:
		add_cursor()
	var tile = game.TileFromPos(x, y)
	var cardData = stat.cards[selected_card.Name]
	if cardData.has("unit"):
		var minTileY = scalar.ToInt(game.map.MinTileYOnBot())
		if tile[1] < minTileY:
			tile[1] = minTileY
	var pos = game.PosFromTile(tile[0], tile[1])
	pos_node.position = Vector2(pos[0], pos[1])
	pos_node.visible = pressed
	get_node("../../Map/Tile").visible = pressed

func get_unit(name, x, y):
	var node = resource.UNIT[name].instance()
	node.InitDummy(x, y, game, self)
	node.modulate = Color(1.0, 1.0, 1.0, 0.5)
	return node

func clear_cursor():
	for child in get_node("../../BattleField/CursorPos").get_children():
		child.queue_free()

func mark_action(input):
	if not action_markers.has(input.Step):
		action_markers[input.Step] = []
	var pos_node = get_node("../../BattleField/CursorPos")
	for child in pos_node.get_children():
		var global_pos = child.global_position
		pos_node.remove_child(child)
		get_node("../../BattleField").add_child(child)
		child.global_position = global_pos
		action_markers[input.Step].append(child)

func show_message(msg, pos_y):
	if team.to_lower() == "red":
		return
	var msgBar = get_node("../../BattleField/MessageBar")
	var pos_x = msgBar.rect_position.x
	msgBar.text = msg
	$Tween.interpolate_property(msgBar, "rect_position", Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 40), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(msgBar, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func update_cards():
	for i in range(HAND_SIZE):
		$Cards.get_node("Card%s" % (i+1)).get_node("Icon").texture = resource.ICON[hand[i].Name]

func Team():
	return team

func Update():
	energy += ENERGY_PER_FRAME
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	$Energy.value = energy
	
	if action_markers.has(game.step):
		for node in action_markers[game.step]:
			node.queue_free()

func Do(action):
	if action.Card.Name == "":
		if action.Message == "":
			return "invalid action: %s" % action
		else:
			# TODO: display opponents message
			return null
	
	# convert position to int
	var pos = game.PosFromTile(action.TileX, action.TileY)
	if no_deck:
		var err = useCard(action.Card, pos[0], pos[1])
		if err != null:
			return err
	else:
		var index = -1
		for i in range(len(hand)):
			var card = hand[i]
			if card.Name == action.Card.Name:
				index = i
				break
		if index < 0:
			return "card not found: %s" % action.Card.Name
	
		var cost = stat.cards[action.Card.Name]["cost"]
		if energy < cost:
			return "not enough energy: %s" % action.Card.Name
			
		var err = useCard(action.Card, pos[0], pos[1])
		if err != null:
			return err
		
		energy -= cost
		hand[index] = pending[0]
		pending.pop_front()
		pending.append(action.Card)
		update_cards()
		selected_card = null
		get_node("../../Map/RedArea").modulate = Color(1.0, 0, 0, 0)
	return null

func actPosValidate(x, y):
	return "invaild pos: %d,%d" % [scalar.ToInt(x), scalar.ToInt(y)]

func findKnight(name):
	for id in knightIds:
		var u = game.FindUnit(id)
		if u.Name() == name:
			return u
	return null

func useCard(c, posX, posY):
	var card = stat.cards[c.Name]
	if not card.has("unit"):
		var k = findKnight(card["caster"])
		if k == null:
			return "should not be here"
		if not k.CastSkill(posX, posY):
			return "%s cannot cast skill now" % k.Name()
	else:
		var name = card["unit"]
		var count = card["count"]
		var offsetX = card["offsetX"]
		var offsetY = card["offsetY"]
		for i in range(count):
			game.AddUnit(name, c.Level, posX+offsetX[i], posY+offsetY[i], self)
	return null

func OnKnightDead(knight):
	for i in range(len(knightIds)):
		var id = knightIds[i]
		if id == knight.Id():
			knightIds[i] = 0
			break
	removeCard(knight.Skill())

func removeCard(name):
	if no_deck:
		return
	for i in range(len(hand)):
		var c = hand[i]
		if c.Name == name:
			hand[i] = pending[0]
			pending.pop_front()
			return
	for i in range(len(pending)):
		var c = pending[i]
		if c.Name == name:
			pending.remove(i)
			return