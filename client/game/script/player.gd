extends node

const MAX_ENERGY = 10000
const START_ENERGY = 7000
const ENERGY_PER_FRAME = 40
const HAND_SIZE = 4

var id = ""
export(String, "home", "visitor") var team
var energy = 0
var hand = []
var pending = []
var knights = []

var game

func _init(p, g):
	id = p.Id
	team = p.Team
	energy = START_ENERGY
	for i in range(len(p.Deck)):
		var card = p.Deck[i]
		if i < HAND_SIZE:
			hand.append(card)
		else:
			pending.append(card)

func update():
	energy += ENERGY_PER_FRAME
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY

func do(action):
	if action.Card.Name == "":
		if action.Message == "":
			print("invalid action: " + action)
			return
		else:
			# TODO: display opponents message
			return
	
	var index = -1
	for i in range(len(hand)):
		var card = hand[i]
		if card.Name == action.Card.Name:
			index = i
	if index < 0:
		print("card not found: " + action.Card.Name)
		return

	var cost = stat.cost[action.Card.Name]
	if energy < cost:
		print("not enough energy: " + action.Card.Name)
		return
	energy -= cost
	
	hand[index] = pending[0]
	pending.pop_front()
	pending.append(action.Card)
	
	useCard(action.Card, action.PosX, action.PosY)

func useCard(card, posX, posY):
	match card.Name:
		"archers":
			game.AddUnit("archer", team, card.Level, posX - 5, posY)
			game.AddUnit("archer", team, card.Level, posX + 5, posY)
