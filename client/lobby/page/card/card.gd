extends CenterContainer

onready var slot_btns = [
	$MarginContainer/VBoxContainer/Slots/HBoxContainer/Slot0,
	$MarginContainer/VBoxContainer/Slots/HBoxContainer/Slot1,
	$MarginContainer/VBoxContainer/Slots/HBoxContainer/Slot2,
	$MarginContainer/VBoxContainer/Slots/HBoxContainer/Slot3,
	$MarginContainer/VBoxContainer/Slots/HBoxContainer/Slot4,
]

onready var knights = [
	$MarginContainer/VBoxContainer/Knights/Center,
	$MarginContainer/VBoxContainer/Knights/Left,
	$MarginContainer/VBoxContainer/Knights/Right,
]

onready var troops = [
	$MarginContainer/VBoxContainer/Troops/VBoxContainer/Card,
	$MarginContainer/VBoxContainer/Troops/VBoxContainer2/Card,
	$MarginContainer/VBoxContainer/Troops/VBoxContainer2/Card2,
	$MarginContainer/VBoxContainer/Troops/VBoxContainer3/Card,
	$MarginContainer/VBoxContainer/Troops/VBoxContainer3/Card2,
	$MarginContainer/VBoxContainer/Troops/VBoxContainer4/Card,
]

func _ready():
	for slot in slot_btns:
		slot.connect("button_up", self, "deck_change", [slot])

func invalidate():
	var selected = user.User.DeckSelected
	$MarginContainer/VBoxContainer/Slots/HBoxContainer/Current.text = "%d" % (selected + 1)
	slot_btns[selected].pressed = true

	var deck = user.User.Decks[selected]
	for i in range(deck.Knights.size()):
		var name = deck.Knights[i]
		var main_node = knights[i].get_node("Card/Main")
		var data = stat.cards[name]
		main_node.get_node("Icon").texture = resource.ICON[name]
		main_node.get_node("VBoxContainer/Top/Energy/Label").text = "%d" % (data.cost / 1000)

	for i in range(deck.Troops.size()):
		var name = deck.Troops[i]
		var main_node = troops[i].get_node("Main")
		var data = stat.cards[name]
		main_node.get_node("Icon").texture = resource.ICON[name]
		main_node.get_node("VBoxContainer/Top/Energy/Label").text = "%d" % (data.cost / 1000)

func deck_change(btn):
	var pressed_num = int(btn.name[-1])
	var request = http.new_request(HTTPClient.METHOD_POST, "/edit/deck/change", {"num":pressed_num})
	var response = yield(request, "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	user.User.DeckSelected = pressed_num
	invalidate()