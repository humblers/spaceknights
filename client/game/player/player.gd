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
var drawTimer = 0
var knightIds = {}
var score = 0
var statRatios = {}
var game

func Init(playerData, game):
	team = playerData.Team
	energy = START_ENERGY
	score = game.LEADER_SCORE + game.WING_SCORE * 2
	self.game = game
	for c in playerData.Deck:
		var card = stat.NewCard(c)
		if card.Side != stat.Center:
			if len(hand) < HAND_SIZE:
				hand.append(card)
			else:
				pending.append(card)
		if card.Type == stat.KnightCard:
			addKnight(card.Name, card.Level, card.Side)
	applyLeaderSkill()

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
	if canDrawCard():
		drawCard(emptyIdx.pop_front())
	else:
		drawTimer -= 1

func canDrawCard():
	if drawTimer > 0:
		return false
	if len(emptyIdx) <= 0:
		return false
	return true


func drawCard(index):
	var next = pending.pop_front()
	hand[index] = next
	drawTimer = DRAW_INTERVAL

func Do(action):
	if action.Card.Name == "":
		if action.Message == "":
			return "invalid action: %s" % action
		else:
			# TODO: display opponents message
			return null

	var index = findCard(hand, action.Card.Name)
	if index < 0:
 		return "card not found: %s, step: %s" % [action.Card.Name, game.Step()]
	var card = hand[index]
	
	var err = canUseCard(card, action.TileX, action.TileY)
	if err != null:
		return err
	useCard(card, action.TileX, action.TileY)
	
	removeCardFromHand(index)
	pending.append(card)
	return null

func canUseCard(card, tileX, tileY):
	if energy < card.Cost:
		return "not enough energy: %s" % card.Name
	if not game.IsValidTile(tileX, tileY):
		return "invalid tile index: (%d, %d)" % [tileX, tileY]
	if not CanUseAnywhere(card):
		if team == "Red" and tileY > game.Map().MaxTileYOnTop():
			return "can't place card on tileY: %d" % tileY
		if team == "Blue" and tileY < game.Map().MinTileYOnBot():
			return "can't place card on tileY: %d" % tileY
	if card.Type == stat.KnightCard:
		var knight = findKnight(card.Name)
		if knight == null:
			return "%s already dead" % knight.Name()
		if not knight.CanCastSkill():
			return "%s cannot cast skill now" % knight.Name()
	return null

func CanUseAnywhere(card):
	if card.Type == stat.KnightCard:
		var skill = stat.units[card.Name].skill.wing
		if not skill.has("unit"):
			return true
		else:
			if stat.units[skill.unit].type != stat.Building:
				return true
	return false

func findCard(from, name):
	for i in len(from):
		var card = from[i]
		if card != null and card.Name == name:
			return i
	return -1

func removeCardFromHand(index):
	hand[index] = null
	emptyIdx.append(index)

func removeCardFromPending(index):
	pending.remove(index)

func findKnight(name):
	for side in knightIds:
		var id = knightIds[side]
		var u = game.FindUnit(id)
		if u != null and u.Name() == name:
			return u
	return null

func useCard(card, tileX, tileY):
	var pos = game.PosFromTile(tileX, tileY)
	var posX = pos[0]
	var posY = pos[1]
	if card.Type == stat.KnightCard:
		findKnight(card.Name).CastSkill(posX, posY)
	else:
		for i in range(card.Count):
			game.AddUnit(card.Unit, card.Level, posX+card.OffsetX[i], posY+card.OffsetY[i], self)
	energy -= card.Cost

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
	var index = findCard(hand, knight.Name())
	if index >= 0:
		removeCardFromHand(index)
	index = findCard(pending, knight.Name())
	if index >= 0:
		removeCardFromPending(index)
