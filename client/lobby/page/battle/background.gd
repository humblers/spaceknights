extends Control

func _ready():
	event.connect("InvalidatePageBattle", self, "invalidate")

func invalidate():
	$Center/Mothership/AppearAni.play("appear")
	# TODO: restore below code
#	for card in user.DeckSlots[user.DeckSelected]:
#		card = data.NewCard(card)
#		if card.Type == data.SquireCard:
#			continue
#		var deck = get("knight_%s" % card.Side.to_lower())
#		for child in deck.get_children():
#			child.queue_free()
#		var node = knight_resources.get_resource(card.Name).instance()
#		deck.add_child(node)