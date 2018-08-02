extends VBoxContainer

const MAX_ENERGY = 10000
const START_ENERGY = 7000
const ENERGY_PER_FRAME = 40
const HAND_SIZE = 4

const KNIGHT_INITIAL_POSX = [200, 500, 800]
const KNIGHT_INITIAL_POSY = [1600, 1600, 1600]

const INPUT_DELAY_STEP = 10

var team
var energy = 0
var hand = []
var pending = []
var knightIds = []
var no_deck = false

var game

var selected_card = null

func Init(playerData, game):
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
		var id = game.AddUnit(k.Name, k.Level, KNIGHT_INITIAL_POSX[i], KNIGHT_INITIAL_POSY[i], self)
		knightIds.append(id)

	$Energy.max_value = MAX_ENERGY
	$Energy.value = energy
	if not no_deck:
		update_cards()
	if playerData.Id == user.Id:
		connect_input()

func connect_input():
	$BattleField.connect("gui_input", self, "send_input")
	for i in range(HAND_SIZE):
		var button = $Cards.get_node("Card%s/Button" % (i+1))
		button.connect("pressed", self, "select_card", [i])

func send_input(ev):
	if ev is InputEventMouseButton and ev.pressed:
		if selected_card != null:
			var x = int(ev.position.x)
			var y = int(ev.position.y)
			tcp.Send({
					"Step": game.step + INPUT_DELAY_STEP,
					"Action": {
						"Id": "Alice",
						"Card": {
							"Name": selected_card.Name,
							"Level": selected_card.Level,
						},
						"PosX": x,
						"PosY": y,
					},
			})	
	
func select_card(i):
	selected_card = hand[i]

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
		if team == "Red":
			var w = game.World().ToPixel(game.Map().Width())
			var h = game.World().ToPixel(game.Map().Height())
			posX = w - posX
			posY = h - posY
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

