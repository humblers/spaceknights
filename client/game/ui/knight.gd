extends Node2D

export(String, "Left", "Right") var side = "Left"

func _ready():
	for i in range(data.HandSize):
		event.connect("BlueSetHand%d" % [i+1], self, "setHand", [i+1])
	event.connect("BlueHandVanished", self, "offCostVisible")
	event.connect("GameInitialized", self, "init")

func init(game):
	var color = "Red" if game.team_swapped else "Blue"
	var deck
	for p in game.cfg.Players:
		var team = p.Team
		if team != color:
			continue
		deck = p.Deck
	for c in deck:
		var card = data.NewCard(c)
		if side == card.Side:
			var cost = String(card.Cost / 1000)
			$Cost/Label.text = cost
			$Card/Cost/Label.text = cost
			var path = loading_screen.GetCardIconPathInGame(card.Name)
			$Card/Icon.texture = loading_screen.LoadResource(path)

func setHand(hand, index):
	if hand != null and side == hand.Side:
		$Card/AnimationPlayer.play("draw")
		$Cost.visible = true

func offCostVisible(hand):
	if hand != null and side == hand.Side:
		$Cost.visible = false