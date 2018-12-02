extends Node

class_name Player

const MAX_ENERGY = 10000
const START_ENERGY = 7000
const ENERGY_PER_FRAME = 40
const HAND_SIZE = 4
const DRAW_INTERVAL = 30
const INITIAL_KNIGHT_POSITION_X = {
	"Left": 200,
	"Center": 500,
	"Right": 800,
}
const INITIAL_KNIGHT_POSITION_Y = {
	"Left": 1350,
	"Center": 1450,
	"Right": 1350,
}
const INPUT_DELAY_STEP = 10

var team
var energy = 0
var hand = []
var pending = []
var emptyIdx = []
var drawCounter = 0
var knightIds = {}
var score = 0
var statRatios = {}
var game

func Init(playerData, game):
	team = playerData.Team
	energy = START_ENERGY
	score = game.LEADER_SCORE + game.WING_SCORE * 2
	self.game = game
	for i in len(playerData.Deck):
		var c = playerData.Deck[i]
		var card = stat.NewCard(c)
		if i < HAND_SIZE:
			hand.append(card)
		else:
			pending.append(card)
		if card.Type == stat.KnightCard:
			addKnight(card.Name, card.Level, card.Side)
	applyLeaderSkill()
	return self

func Score():
	return score

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

func addKnight(name, level, side):
	var x = INITIAL_KNIGHT_POSITION_X[side]
	var y = INITIAL_KNIGHT_POSITION_Y[side]
	if team == "Red":
		x = game.FlipX(x)
		y = game.FlipY(y)
	var knight = game.AddUnit(name, level, x, y, self)
	knightIds[side] = knight.Id()
	return knight

func applyLeaderSkill():
	game.FindUnit(knightIds[stat.Center]).SetAsLeader()
	
	# apply hp buff
	for side in knightIds:
		var id = knightIds[side]
		var knight = game.FindUnit(id)
		var hp = knight.Hp()
		var divider = 1
		var ratios = StatRatios("hpratio")
		for i in range(len(ratios)):
			hp *= ratios[i]
			divider *= 100
		knight.SetHp(hp / divider)
	
func Update():
	energy += ENERGY_PER_FRAME
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	drawCard()

func Do(action):
	if action.Card.Name == "":
		if action.Message == "":
			return "invalid action: %s" % action
		else:
			# TODO: display opponents message
			return null

	# find card in hand
	var index = -1
	for i in len(hand):
		var card = hand[i]
		if card.Name == action.Card.Name:
			index = i
			break

	if index < 0:
 		return "card not found: %s, step: %s" % [action.Card.Name, game.Step()]

	# check energy
	var cost = stat.cards[action.Card.Name]["Cost"]
	if energy < cost:
		return "not enough energy: %s" % action.Card.Name

	var err = useCard(action.Card, action.TileX, action.TileY)
	if err != null:
		return err
	
	# decrement energy
	energy -= cost
	
	# put empty card
	if index >= 0:
		hand[index] = {}
		pending.append(action.Card)
		emptyIdx.append(index)
	return null

func findKnight(name):
	for side in knightIds:
		var id = knightIds[side]
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
	var isKnight = u["type"] == stat.Knight
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

func drawCard():
	if drawCounter > 0:
		drawCounter -= 1
		return
	if len(emptyIdx) == 0:
		return
	var next = pending.pop_front()
	var idx = emptyIdx.pop_front()
	hand[idx] = next
	drawCounter = DRAW_INTERVAL

func OnKnightDead(knight):
	for side in knightIds:
		var id = knightIds[side]
		if id == knight.Id():
			knightIds[side] = 0
			if side == stat.Center:
				score -= game.LEADER_SCORE
			else:
				score -= game.WING_SCORE
			break
	removeCard(knight.Name())

func removeCard(name):
	for i in range(len(hand)):
		var c = hand[i]
		if c.Name == name:
			hand[i] = pending.pop_front()
			return
	for i in range(len(pending)):
		var c = pending[i]
		if c.Name == name:
			pending.remove(i)
			return
