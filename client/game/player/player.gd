extends Node

class_name Player

const MAX_ENERGY = 10000
const START_ENERGY = 7000
const ENERGY_PER_FRAME = 40
const HAND_SIZE = 4
const DRAW_INTERVAL = 30
const KNIGHT_TILE_NUM_X = 4
const KNIGHT_TILE_NUM_Y = 4
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
		var card = data.NewCard(c)
		if card.Side != data.Center:
			if len(hand) < HAND_SIZE:
				hand.append(card)
			else:
				pending.append(card)
		if card.Type == data.KnightCard:
			addKnight(card.Name, card.Level, card.Side)
	applyLeaderSkill()

func TileValid(tx, ty, isSpell):
	var nx = game.map.TILE_NUM_X
	var ny = game.map.TILE_NUM_Y
	if tx < 0 or tx >= nx:
		return false
	if ty < 0 or ty >= ny:
		return false
	if not isSpell:
		if team == "Red":
			tx = nx - tx
			ty = ny - ty
		if ty < ny/2-5:
			return false
		if ty <= ny/2 and ty >= ny/2-1:
			return false
		if ty < ny/2-1:
			var opponentSide = data.Left
			if tx < nx/2:
				opponentSide = data.Right
			if not game.FindPlayer(opponentTeam()).KnightDead(opponentSide):
				return false
	return true

func KnightDead(side):
	return knightIds[side] == 0

func TileRectValid(tr, isSpell):
	for i in range(game.TileRectMinX(tr), game.TileRectMaxX(tr)):
		for j in range(game.TileRectMinY(tr), game.TileRectMaxY(tr)):
			if not TileValid(i, j, isSpell):
				return false
	return true

func opponentTeam():
	if team == "Blue":
		return "Red"
	return "Blue"
		
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
	game.FindUnit(knightIds[data.Center]).SetAsLeader()
	
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

	# find card in hand
	var index = findCard(hand, action.Card.Name)
	if index < 0:
 		return "card not found: %s, step: %s" % [action.Card.Name, game.Step()]
	var card = hand[index]
	
	# energy check
	if energy < card.Cost:
		return "not enough energy: %s" % card.Name
	
	# tile check
	var num = data.CardTileNum(card)
	var nx = num[0]
	var ny = num[1]
	var tr = game.NewTileRect(action.TileX, action.TileY, nx, ny)
	var isSpell = data.CardIsSpell(card)
	if not TileRectValid(tr, isSpell):
		return "invalid tile: %s" % tr
	if not isSpell:
		tr = FindUnoccupiedTileRect(tr, 0)
		if tr == null:
			return "cannot find unoccupied tile"
		else:
			action.TileX = tr.x
			action.TileY = tr.y
	
	# knight check
	if card.Type == data.KnightCard:
		var knight = findKnight(card.Name)
		if knight == null:
			return "knight not found: %s" % card.Name
		if not knight.CanCastSkill():
			return "%s cannot cast skill now" % knight.Name()

	useCard(card, action.TileX, action.TileY)	
	removeCardFromHand(index)
	pending.append(card)
	return null

func FindUnoccupiedTileRect(tr, offset):
	if offset > game.map.TILE_NUM_Y:
		return null
	var min_x = tr.x - offset
	var max_x = tr.x + offset
	var min_y = tr.y - offset
	var max_y = tr.y + offset
	for i in range(min_x, max_x + 1):
		for j in range(min_y, max_y + 1):
			if i != min_x and i != max_x:
				if j != min_y and j != max_y:
					continue
			var candidate = game.NewTileRect(i, j, tr.numX, tr.numY)
			if not TileRectValid(candidate, false):
				continue
			if game.Occupied(candidate):
				continue
			return candidate
	return FindUnoccupiedTileRect(tr, offset + 1)

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
	if card.Type == data.KnightCard:
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
			if side == data.Center:
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
