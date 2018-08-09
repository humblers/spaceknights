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
	var field = get_node("../../BattleField")
	field.connect("gui_input", self, "send_input", [field, null])
	for i in range(HAND_SIZE):
		var button = $Cards.get_node("Card%s/Button" % (i+1))
		button.connect("gui_input", self, "send_input", [button, i])

func send_input(ev, node, i):
	var field = get_node("../../BattleField")
	var pos = field.get_local_mouse_position()
	if ev is InputEventMouseMotion:
		if pressed:
			if selected_card == null:
				return
			if not field.get_rect().has_point(pos):
				return
			update_cursor(int(pos.x), int(pos.y))

	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			if i != null:
				selected_card = hand[i]
		else:
			if not field.get_rect().has_point(pos):
				clear_cursor()
				return
			if selected_card == null:
				show_message("No Selected Card", pos.y)
				return
			if energy < stat.cards[selected_card.Name]["cost"]:
				show_message("Not Enought Energy", pos.y)
				clear_cursor()
				return
			var x = int(pos.x)
			var y = int(pos.y)
			if game.team_swapped:
				x = game.FlipX(x)
				y = game.FlipY(y)
			var input = {
					"Step": game.step + INPUT_DELAY_STEP,
					"Action": {
						"Id": id,
						"Card": {
							"Name": selected_card.Name,
							"Level": selected_card.Level,
						},
						"PosX": x,
						"PosY": y,
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

func update_cursor(x, y):
	var tile_pos = game.PosFromTile(game.TileFromPos(x, y))
	var pos_node = get_node("../../BattleField/CursorPos")
	pos_node.position = tile_pos
	if pos_node.get_child_count() > 0:
		return
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

func get_unit(name, x, y):
	var node = resource.UNIT[name].instance()
	node.InitDummy(x, y, game, self)
	node.modulate = Color(1.0, 1.0, 1.0, 0.5)
	return node

func update_cards():
	for i in range(HAND_SIZE):
		$Cards.get_node("Card%s" % (i+1)).get_node("Icon").texture = resource.ICON[hand[i].Name]

func show_message(msg, pos_y):
	if team.to_lower() == "red":
		return
	var msgBar = get_node("../../BattleField/MessageBar")
	var pos_x = msgBar.rect_position.x
	msgBar.text = msg
	$Tween.interpolate_property(msgBar, "rect_position", Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 40), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(msgBar, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

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
	action.PosX = int(action.PosX)
	action.PosY = int(action.PosY)
	if no_deck:
		var err = useCard(action.Card, action.PosX, action.PosY)
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
			
		var err = useCard(action.Card, action.PosX, action.PosY)
		if err != null:
			return err
		
		energy -= cost
		hand[index] = pending[0]
		pending.pop_front()
		pending.append(action.Card)
		update_cards()
		selected_card = null
	return null

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