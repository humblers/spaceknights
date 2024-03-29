extends Control

export(NodePath) onready var gold_label = get_node(gold_label)
export(NodePath) onready var cash_label = get_node(cash_label)

export(NodePath) onready var card1 = get_node(card1)
export(NodePath) onready var card2 = get_node(card2)
export(NodePath) onready var card3 = get_node(card3)
export(NodePath) onready var card4 = get_node(card4)
export(NodePath) onready var card5 = get_node(card5)

export(NodePath) onready var open_anim = get_node(open_anim)
export(NodePath) onready var chest_icon = get_node(chest_icon)
export(NodePath) onready var skip_button = get_node(skip_button)

var hidden_cards = []

export(String, "Silver", "Gold", "Diamond", "D-Matter", "E-Matter") var chest_name = "Silver"
export(int) var gold = 0
export(int) var cash = 0
export(Dictionary) var cards = {
	"archers": 3,
	"legion": 1,
}
export(Dictionary) var user_cards = {
	"archers": {"Level": 0, "Holding": 5},
	"legion": {"Level": 0, "Holding": 3},
}
export(bool) var test_open = false

func _ready():
	card1.connect("button_up", self, "flip_card", [card1])
	card2.connect("button_up", self, "flip_card", [card2])
	card3.connect("button_up", self, "flip_card", [card3])
	card4.connect("button_up", self, "flip_card", [card4])
	card5.connect("button_up", self, "flip_card", [card5])
	skip_button.connect("button_up", self, "skip_open")
	if test_open:
		PopUp(chest_name, gold, cash, cards, user_cards)

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		if len(hidden_cards) <= 0:
			visible = false

func PopUp(chest_name, gold, cash, cards, user_cards = user.Cards):
	chest_icon.Open(chest_name)
	gold_label.text = "+%d" % gold
	cash_label.text = "+%d" % cash
	var i = 1
	for name in cards:
		var card = get("card%d" % i)
		var card_item = card.get_node("Item")
		var card_data = user_cards[name]
		card_data.Name = name
		card_item.Invalidate(data.NewCard(card_data), cards[name])
		hidden_cards.append(card)
		i += 1
	open_anim.play("open%d" % len(cards))
	visible = true
	
func flip_card(card):
	var card_anim = card.get_node("AnimationPlayer")
	if open_anim.is_playing() or card_anim.is_playing():
		return
	if not hidden_cards.has(card):
		return
	card_anim.play("cardflip")
	yield(card_anim, "animation_finished")
	hidden_cards.erase(card)
	
func skip_open():
	for card in hidden_cards:
		flip_card(card)
		