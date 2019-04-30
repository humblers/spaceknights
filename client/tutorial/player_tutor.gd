extends Player

func Init(playerData, game):
	.Init(playerData, game)
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
		PHASES.REQUEST_ARCHERS:
			event.connect("StudentUseCard", self, "useFootmans")
		PHASES.REQUEST_GIANT_GARGOYLE:
			event.disconnect("StudentUseCard", self, "useFootmans")
			game.AddUnit("giant_gargoyle", 0,
					game.RED_PLAYER_CARD_POS_X, game.RED_PLAYER_CARD_POS_Y,
					self)
			game.call_deferred("ForwardToNextPhase")
		PHASES.REQUEST_RANGE_SQUIRES:
			var archers = data.NewCard({"Name": "archers", "Level": 0})
			useCard(archers, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 2))
			var starfires = data.NewCard({"Name": "starfiresquadron", "Level": 0})
			useCard(starfires, randi() % game.Map().TileNumX(), randi() % (game.Map().TileNumY() / 2 - 2))
			game.call_deferred("ForwardToNextPhase")
		PHASES.REQUEST_FOOTMANS_WAVE:
			var footmans = data.NewCard({"Name": "footmans", "Level": 0})
			var tileX = randi() % game.Map().TileNumX()
			var tileY = randi() % (game.Map().TileNumY() / 2 - 2)
			for i in range(game.FOOTMAN_WAVE_COUNT):
				useCard(footmans, tileX, tileY)
			game.call_deferred("ForwardToNextPhase")
		PHASES.TO_THE_VICTORY:
			useRandomCards()