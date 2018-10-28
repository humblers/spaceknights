extends Control

const MAX_ENERGY = 10000
const START_ENERGY = 7000
const ENERGY_PER_FRAME = 40
const HAND_SIZE = 4
const ROLLING_INTERVAL_STEP = 30

const KNIGHT_LEADER_INDEX = 0
const KNIGHT_INITIAL_POSX = [500, 200, 800]
const KNIGHT_INITIAL_POSY = [1500, 1400, 1400]

const INPUT_DELAY_STEP = 10

var id
var team
var score
var energy = 0
var hand = []
var pending = []
var emptyIdx = []
var rollingCounter = 0
var knightIds = []
var statRatios = {}
var no_deck = false

var game

var selected_card = null
var action_markers = {}

func Init(playerData, game):
	id = playerData.Id
	team = playerData.Team
	score = game.LEADER_SCORE + game.WING_SCORE * 2
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

	$Energy.max_value = MAX_ENERGY
	$Energy.value = energy
	if not no_deck:
		update_cards()

func Score():
	return score

func connect_input():
	get_node("../../BattleField").connect("gui_input", self, "gui_input")
	for i in range(HAND_SIZE):
		var button = $Cards.get_node("Area%s/Card/Button" % (i+1))
		button.connect("gui_input", self, "button_input", [i])

func gui_input(ev):
	var field = get_node("../../BattleField")
	var pos = field.get_local_mouse_position()
	var belowField = pos.y > field.get_rect().end.y - field.rect_position.y
	if ev is InputEventMouseButton:
		update_tile_visible(ev.pressed)
		get_node("../../BattleField/CursorPos").visible = ev.pressed
		if not ev.pressed and not belowField:
			if selected_card == null:
				show_message("No Selected Card", pos.y)
				return
			if energy < stat.cards[selected_card.Name]["Cost"]:
				show_message("Not Enought Energy", pos.y)
				clear_cursor()
				return
			if name == "Blue":
				pos = get_node("../../BattleField/CursorPos").position
			var x = int(pos.x)
			var y = int(pos.y)
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
			selected_card["InvisibleTo"] = game.step + INPUT_DELAY_STEP
			selected_card = null
			mark_action(input)
	if not ev is InputEventMouseMotion:
		return
	if name == "Blue":
		if belowField:
			clear_cursor()
			return
		update_cursor(int(pos.x), int(pos.y))

func button_input(ev, i):
	if ev is InputEventMouseButton and ev.pressed:
		selected_card = hand[i]
	if name == "Blue":
		gui_input(ev)

func add_cursor():
	var pos_node = get_node("../../BattleField/CursorPos")
	var cardData = stat.cards[selected_card.Name]
	var cursor
	if cardData.has("caster"):
		var k = findKnight(cardData["caster"])
		cursor = $Cursor.get_resource(k.Name())
	else:
		cursor = $Cursor.get_resource("unit")
		var name = cardData["Unit"]
		var count = cardData["Count"]
		var offsetX = cardData["OffsetX"]
		var offsetY = cardData["OffsetY"]
		for i in range(count):
			pos_node.add_child(get_unit(name, offsetX[i], offsetY[i]))
	cursor = cursor.instance()
	pos_node.add_child(cursor)
	pos_node.move_child(cursor, 0)

func update_cursor(x, y):
	if selected_card == null:
		return
	var d = stat.cards[selected_card.Name]
	var unit = stat.units[d.Unit]
	if unit["type"] == "Knight":
		var k = findKnight(d.Unit)
		if k == null:
			return
		if k.Skill().has("unit"):
			unit = stat.units[k.Skill()["unit"]]
		else:
			unit = null
	var pos_node = get_node("../../BattleField/CursorPos")
	if pos_node.get_child_count() <= 0:
		add_cursor()
	var tile = game.TileFromPos(x, y)
	if unit:
		var nx = 1
		var ny = 1
		var minTileY = 0
		var maxTileY = game.Map().TileNumY() - 1
		if unit and unit["type"] == "Building":
			nx = unit["tilenumx"]
			ny = unit["tilenumy"]
		if name == "Blue":
			minTileY = game.Map().MinTileYOnBot()
		else:
			maxTileY = game.Map().MaxTileOnTop()
		tile[1] = int(clamp(tile[1], minTileY, maxTileY))
		var res = avoid_occupied_tiles(tile[0], tile[1], nx, ny, minTileY, maxTileY)
		if res[1] == null:
			var tr = res[0]
			tile[0] = (tr.l + tr.r) / 2
			tile[1] = (tr.t + tr.b) / 2
	var pos = game.PosFromTile(tile[0], tile[1])
	pos_node.position = Vector2(pos[0], pos[1])

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

func update_tile_visible(pressed):
	if selected_card == null:
		return
	var d = stat.cards[selected_card.Name]
	var unit = stat.units[d.Unit]
	if unit["type"] == "Knight":
		var k = findKnight(d.Unit)
		if k == null:
			return
		if k.Skill().has("unit"):
			unit = stat.units[k.Skill()["unit"]]
		else:
			unit = null
	get_node("../../Map/TileSpell").visible = unit == null and pressed
	get_node("../../Map/TileUnit").visible = unit != null and pressed

func get_unit(name, x, y):
	var node = $Unit.get_resource(name).instance()
	node.InitDummy(x, y, game, self, false)
	node.modulate = Color(1.0, 1.0, 1.0, 0.5)
	return node

func clear_cursor():
	for child in get_node("../../BattleField/CursorPos").get_children():
		child.queue_free()

func mark_action(input):
	if not action_markers.has(input.Step):
		action_markers[input.Step] = []
	if name == "Blue":
		var pos_node = get_node("../../BattleField/CursorPos")
		for child in pos_node.get_children():
			var global_pos = child.global_position
			pos_node.remove_child(child)
			get_node("../../BattleField").add_child(child)
			child.global_position = global_pos
			action_markers[input.Step].append(child)
	else:
		var default_cursor = $Cursor.get_resource("unit").instance()
		var pos = game.PosFromTile(input.Action.TileX, input.Action.TileY)
		default_cursor.position.x = pos[0]
		default_cursor.position.y = pos[1]
		get_node("../../BattleField").add_child(default_cursor)
		action_markers[input.Step].append(default_cursor)

func show_message(msg, pos_y):
	if name == "Blue":
		var msgBar = get_node("../../BattleField/MessageBar")
		var pos_x = msgBar.rect_position.x
		msgBar.text = msg
		$Tween.interpolate_property(msgBar, "rect_position", Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 40), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.interpolate_property(msgBar, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()

func update_cards():
	$Cards/Area0/Next/Icon.texture = $Icon.get_resource(pending[0].Name)
	$Cards/Area0/Next/Pending.visible = rollingCounter > 0
	$Cards/Area0/Next/Pending/Time.text = String(rollingCounter / 10 + 1)
	for i in range(HAND_SIZE):
		var card = hand[i]
		var btn_node = $Cards.get_node("Area%d/Card/%s" % [i+1, "Button"])
		var icon_node = $Cards.get_node("Area%d/Card/%s" % [i+1, "Icon"])
		var cost_node = $Cards.get_node("Area%d/Card/%s" % [i+1, "Cost"])
		var modulate = Color(1, 1, 1, 1)
		match card:
			selected_card:
				modulate = Color(1, 0.69, 0, 1)
				continue
			{"Name":"", ..}:
				btn_node.visible = false
				icon_node.texture = null
			{"InvisibleTo": var to, ..}:
				if to < game.step:
					btn_node.visible = false
					icon_node.texture = null
				else:
					card.erase("InvisibleTo")
			_:
				btn_node.visible = true
				icon_node.texture = $Icon.get_resource(hand[i].Name)
				cost_node.text = str(stat.cards[hand[i].Name].Cost/1000)
		icon_node.modulate = modulate

func Team():
	return team

func StatRatios(name):
	if not statRatios.has(name):
		return []
	return statRatios[name]

func AddStatRatio(name, ratio):
	if not statRatios.has(name):
		statRatios[name] = []
	statRatios[name].append(ratio)

func AddKnights(knights):
	for i in range(len(knights)):
		var k = knights[i]
		var x = KNIGHT_INITIAL_POSX[i]
		var y = KNIGHT_INITIAL_POSY[i]
		if team == "Red":
			x = game.FlipX(x)
			y = game.FlipY(y)
		var id = game.AddUnit(k.Name, k.Level, x, y, self)
		var knight = game.FindUnit(id)
		if not get_node("../../Map/MotherShips/%s" % team).show_anim_finished:
			knight.visible = false
		if i == KNIGHT_LEADER_INDEX:
			knight.SetAsLeader()
			knight.side = "Center"
		elif i == 1:
			knight.side = "Left"
		else:
			knight.side = "Right"
		knightIds.append(id)

func Update():
	if game.step == game.KNIGHT_INITIAL_STEP:
		connect_input()
	energy += ENERGY_PER_FRAME
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	$Energy.value = energy

	rollingCard()
	update_cards()

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
	action.TileX = int(action.TileX)
	action.TileY = int(action.TileY)
	if no_deck:
		var err = useCard(action.Card, action.TileX, action.TileY)
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
	
		var cost = stat.cards[action.Card.Name]["Cost"]
		if energy < cost:
			return "not enough energy: %s" % action.Card.Name

		var err = useCard(action.Card, action.TileX, action.TileY)
		if err != null:
			return err
		
		energy -= cost
		hand[index] = {"Name":"", "Level":0}
		pending.append(action.Card)
		emptyIdx.append(index)
	return null

func findKnight(name):
	for id in knightIds:
		var u = game.FindUnit(id)
		if u != null and u.Name() == name:
			return u
	return null

func useCard(c, tileX, tileY):
	var pos = game.PosFromTile(tileX, tileY)
	if pos[2] != null:
		return pos[2]
	var posX = pos[0]
	var posY = pos[1]
	var d = stat.cards[c.Name]
	var name = d.Unit
	var u = stat.units[name]
	var k = findKnight(name)
	var isKnight = u["type"] == "Knight"
	if not isKnight or k.Skill().has("unit"):
		if team == "Red" and tileY > game.Map().MaxTileYOnTop():
			return "can't place card on tileY: %d" % tileY
		if team == "Blue" and tileY < game.Map().MinTileYOnBot():
			return "can't place card on tileY: %d" % tileY
	if isKnight:
		if k == null:
			return "should not be here"
		if not k.CastSkill(posX, posY):
			return "%s cannot cast skill now" % k.Name()
	else:
		for i in range(d.Count):
			game.AddUnit(name, c.Level, posX+d.OffsetX[i], posY+d.OffsetY[i], self)
	return null

func rollingCard():
	if rollingCounter > 0:
		rollingCounter -= 1
		return
	if len(emptyIdx) == 0:
		return
	var next = pending.pop_front()
	var idx = emptyIdx.pop_front()
	hand[idx] = next
	rollingCounter = ROLLING_INTERVAL_STEP

func OnKnightDead(knight):
	var isLeader = false
	for i in range(len(knightIds)):
		var id = knightIds[i]
		if id == knight.Id():
			knightIds[i] = 0
			if i == 0:
				isLeader = true
			break
	removeCard(knight.Name())
	if isLeader:
		score -= game.LEADER_SCORE
	else:
		score -= game.WING_SCORE
	get_node("../../Map/MotherShips/%s" % team).destroy(knight.side)
	expand_spawnable_area(knight)

func expand_spawnable_area(knight):
	if knight.side == "Center":
		return
	var t = knight.client_team
	var s = knight.side
	get_node("../../Map/TileUnit/%s%s" % [t, s]).visible = true

func OnKnightHalfDamaged(knight):
	get_node("../../Map/MotherShips/%s" % team).partial_destroy(knight.side)

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