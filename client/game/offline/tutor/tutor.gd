extends Node

var cfg = config.GAME

var RelativeLvByRarity = {
	data.Common:    0,
	data.Rare:      2,
	data.Epic:      5,
	data.Legendary: 8,
}

func _enter_tree():
	for player in cfg.Players:
		if player.Team != "Red":
			continue
		var difficulty = player.Difficulty
		for card in player.Deck:
			var c = data.NewCard(card)
			card.Level = max(0, difficulty - RelativeLvByRarity[c.Rarity])
	get_node("game").cfg = cfg

func _physics_process(delta):
	var game = get_node("game")
	if game.frame % game.frame_per_step == 0:
		if game.Over():
			set_physics_process(false)
			if user.IssuedAt <= 0:
				return
			if game.score("Blue") > game.score("Red"):
				if user.Rank > 0:
					if user.Medal < data.MedalsPerRank:
						user.Medal += 1
					else:
						user.Rank -= 1
						user.Medal = 1
			elif game.score("Blue") < game.score("Red"):
				if user.Medal <= 0:
					if user.Rank < data.InitialRank:
						user.Rank += 1
						user.Medal = data.MedalsPerRank - 1
				else:
					user.Medal -= 1
			var req = lobby_request.New("/edit/rank/set", 
					{"Rank": user.Rank, "Medal": user.Medal})
			var response = yield(req, "Completed")
			assert(response[0])