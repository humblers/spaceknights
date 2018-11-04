extends Button

var name_

onready var base = $MarginContainer/MarginContainer/VBoxContainer/ItemBase
onready var use = $MarginContainer/MarginContainer/VBoxContainer/CenterContainer2/Use

func invalidate(name, page_card):
	self.name_ = name
	if not self.is_connected("button_up", page_card, "set_pressed_card"):
		self.connect("button_up", page_card, "set_pressed_card", [self])
	if not use.is_connected("button_up", page_card, "set_picked_card"):
		use.connect("button_up", page_card, "set_picked_card", [self])
	if name != null:
		$MarginContainer/MarginContainer/VBoxContainer/CenterContainer2/Use.visible = not user.CardInDeck(name)
		$MarginContainer.rect_size.y = 0 # resizing
		base.get_node("CardFrame/Icon").texture = base.get_node("Icon").get_resource(name_)
		base.get_node("CardFrame/Frame").texture = base.get_node("Frame").get_resource(stat.cards[name_]["Rarity"])
		base.get_node("CardFrame/Control/Energy/Label").text = "%d" % (stat.cards[name_]["Cost"] / 1000)
