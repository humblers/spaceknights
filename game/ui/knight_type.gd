extends Button
var is_creator = true
var name = "+"

func _ready():
	connect("pressed", self, "_on_Button1_pressed")
	set_text(name)

func _on_Button1_pressed():
	var deck_node = get_node("../../../")
	if is_creator:
		deck_node.make_new_deck()
		return
	deck_node.select_knight(name)