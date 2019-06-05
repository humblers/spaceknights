#extends Player
extends "res://game/player/player_ui.gd"

var map_tile_num_x
var map_tile_num_y
var knight
var rival_knight
var posX
var posY

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
			addKnight(card.Name, lv, card.Side)
			if card.Side == data.Center:
				leader = card.Name
	id = playerData.Id
	color = team
	if game.team_swapped:
		color = "Blue" if team == "Red" else "Red"
	init_deck()
	#event.connect("%sHandFocused" % color, self, "handFocused")
	event.emit_signal("%sPlayerInitialized" % color, self)
	
	#addKnight("valkyrie", 1, "Center")
	event.connect("PhaseChanged", self, "phaseChanged")
	map_tile_num_x = game.Map().TileNumX()
	map_tile_num_y = game.Map().TileNumY()
	knight = game.FindUnit(knightIds["Center"])
	posX = knight.PositionX()
	posY = knight.PositionY()
	

func useFootmans(card_used):
	var card = data.NewCard({"Name": "footmans", "Level": 0})
	for i in range(card.Count):
		var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
		game.AddUnit(card.Unit, lv,
				game.RED_PLAYER_CARD_POS_X+card.OffsetX[i],
				game.RED_PLAYER_CARD_POS_Y+card.OffsetY[i],
				self)

func useRandomCards():
	while true:
		var rand_delay = rand_range(game.TUTOR_USE_RANDOM_CARD_MIN_DELAY,game.TUTOR_USE_RANDOM_CARD_MAX_DELAY)
		yield(get_tree().create_timer(rand_delay), "timeout")
		var pool = game.TUTOR_USE_RANDOM_CARD_POOL
		var card = data.NewCard({"Name": pool[randi() % len(pool)], "Level": 0})
		var tileX = randi() % game.Map().TileNumX()
		var tileY = randi() % (game.Map().TileNumY() / 2 - 2)
		useCard(card, tileX, tileY)

func phaseChanged(phase, PHASES):
	match phase:
		PHASES.FOOTMANS:
			var archers = data.NewCard({"Name": "archers", "Level": 0})
			var footmans = data.NewCard({"Name": "footmans", "Level": 0})
			useCard(archers, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 6) + 4)
			yield(get_tree().create_timer(2), "timeout")
			useCard(footmans, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 6) + 4)
			yield(get_tree().create_timer(2), "timeout")
			
func Update():
#	if game.Step() > data.EnergyBoostAfter:
#		energy += ENERGY_PER_FRAME * 6
#	else:
	energy += ENERGY_PER_FRAME * 3
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	if canDrawCard():
		drawCard(emptyIdx.pop_front())
	else:
		drawTimer -= 1
	useRandomCard()
	moveKnight()
	
func moveKnight():
	if game.step % 30 == 0:
		posX = game.World().FromPixel(int((randi() % map_tile_num_x) * 50))
		posY = game.World().FromPixel(int((randi() % map_tile_num_y) * 50))
	knight.moveToPos(posX,posY)
	#knight.moveTo(rival_knight)
	
func useRandomCard():
	var cards = []
	for card in hand:
		if card == null:
			continue
		cards.append(card)
	var card = cards[randi() % len(cards)]
	var input = {
		"Step": game.step + 1,
		"Action": {
			"Id": id,
			"Card": {
				"Name": card.Name,
				"Level": card.Level,
			},
			"TileX": randi() % map_tile_num_x,
			"TileY": randi() % (map_tile_num_y / 2 - 1),
		},
	}
	if game.actions.has(input.Step):
		game.actions[input.Step].append(input.Action)
	else:
		game.actions[input.Step] = [input.Action]
		

func KnightDead(side):
	return knightIds["Center"] == 0