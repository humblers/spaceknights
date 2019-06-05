extends "res://game/player/player_ui.gd"

var initial_hands
var knight
var rival_knight

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
		if card.Type == data.KnightCard and card.Side == data.Center:
			var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
			knight = addKnight(card.Name, lv, card.Side)
			get_node("../../UI/Map").initHero(knight)
			if card.Side == data.Center:
				leader = card.Name
			
	#get_node("../../UI/Map").initHero(addKnight("valkyrie", 1, "Center"))
	#	get_node("UI/Map").initHero(
	id = playerData.Id
	color = team
	if game.team_swapped:
		color = "Blue" if team == "Red" else "Red"
	init_deck()
	event.connect("%sHandFocused" % color, self, "handFocused")
	event.emit_signal("%sPlayerInitialized" % color, self)
	
	initial_hands = hand.duplicate(true)

func Update():
	energy += ENERGY_PER_FRAME * 3
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	if canDrawCard():
		drawCard(emptyIdx.pop_front())
	else:
		drawTimer -= 1
	update_energy()

func useCard(card, tileX, tileY):
	.useCard(card, tileX, tileY)
	#event.emit_signal("StudentUseCard", card)

func drawCard(index):
	var next = initial_hands[index]
	hand[index] = next
	drawTimer = DRAW_INTERVAL
	event.emit_signal("%sSetHand%d" % [color, index+1], hand[index])
	print("next = ", next, "index = ", index)

func addKnight(name, level, side):
	var x = INITIAL_KNIGHT_POSITION_X[side]
	var y = INITIAL_KNIGHT_POSITION_Y[side]
	if team == "Red":
		x = game.FlipX(x)
		y = game.FlipY(y)
	var knight = game.AddUnit(name, level, x, y, self)
	knight.SetSide(side)
	knightIds[side] = knight.Id()
	return knight

func KnightDead(side):
	return knightIds["Center"] == 0