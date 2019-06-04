extends Player

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
#		if card.Type == data.KnightCard:
#			var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
#			addKnight(card.Name, lv, card.Side)
#			if card.Side == data.Center:
#				leader = card.Name
	addKnight("valkyrie", 1, "Center")
	event.connect("PhaseChanged", self, "phaseChanged")

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
		var rand_delay = rand_range(game.TUTOR_USE_RANDOM_CARD_MIN_DELAY,
							game.TUTOR_USE_RANDOM_CARD_MAX_DELAY)
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
			
#		PHASES.REQUEST_ARCHERS:
#			event.connect("StudentUseCard", self, "useFootmans")
#		PHASES.REQUEST_GIANT_GARGOYLE:
#			event.disconnect("StudentUseCard", self, "useFootmans")
#			game.AddUnit("giant_gargoyle", 0,
#					game.RED_PLAYER_CARD_POS_X, game.RED_PLAYER_CARD_POS_Y,
#					self)
#			game.call_deferred("ForwardToNextPhase")
#		PHASES.REQUEST_GARGOYLES:
#			yield(get_tree().create_timer(2), "timeout")
#			var archers = data.NewCard({"Name": "archers", "Level": 0})
#			var starfires = data.NewCard({"Name": "starfiresquadron", "Level": 0})
#			useCard(archers, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 6) + 4)
#			yield(get_tree().create_timer(2), "timeout")
#			useCard(starfires, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 6) + 4)
#			yield(get_tree().create_timer(2), "timeout")
#			useCard(archers, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 6) + 4)
#		PHASES.REQUEST_BOOSTED_SQUIRES:
#			var archers = data.NewCard({"Name": "archers", "Level": 0})
#			var starfires = data.NewCard({"Name": "starfiresquadron", "Level": 0})
#			var footmans = data.NewCard({"Name": "footmans", "Level": 0})
#			yield(get_tree().create_timer(3), "timeout")
#			useCard(footmans, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 6) + 4)
#			yield(get_tree().create_timer(1), "timeout")
#			useCard(archers, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 6) + 4)
#		PHASES.REQUEST_FOOTMANS_WAVE:
#			var footmans = data.NewCard({"Name": "footmans", "Level": 0})
#			var tileX = randi() % game.Map().TileNumX()
#			var tileY = randi() % (game.Map().TileNumY() / 2 - 2)
#			for i in range(game.FOOTMAN_WAVE_COUNT):
#				useCard(footmans, tileX, tileY)
#				yield(get_tree().create_timer(2), "timeout")
#			game.call_deferred("ForwardToNextPhase")
#		PHASES.TO_THE_VICTORY:
#			useRandomCards()