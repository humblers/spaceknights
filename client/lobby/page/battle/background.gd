extends Control

func _ready():
	event.connect("DoneBackgroundProcess", self, "appear")
	event.connect("InvalidatePageBattle", self, "invalidate")

func appear():
	$Center/Mothership/AppearAni.play("appear")

func invalidate():
	for card in user.DeckSlots[user.DeckSelected]:
		card = data.NewCard(card)
		if card.Type == data.SquireCard:
			continue
		var deck = get_node("Center/Mothership/Nodes/Deck/%s/Position/Unit" % card.Side)
		for child in deck.get_children():
			child.queue_free()
		var sprite = Sprite.new()
		sprite.texture = loading_screen.LoadResource("res://atlas/lobby/background.sprites/knights/%s.tres" % card.Name)
		sprite.normal_map = loading_screen.LoadResource("res://atlas/lobby/background_n.png")
		deck.add_child(sprite)