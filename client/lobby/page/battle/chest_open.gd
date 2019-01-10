extends Control

export(NodePath) onready var gold_label = get_node(gold_label)
export(NodePath) onready var cash_label = get_node(cash_label)

export(NodePath) onready var card1 = get_node(card1)
export(NodePath) onready var card2 = get_node(card2)
export(NodePath) onready var card3 = get_node(card3)
export(NodePath) onready var card4 = get_node(card4)
export(NodePath) onready var card5 = get_node(card5)

export(NodePath) onready var open_anim = get_node(open_anim)

var hidden_cards = []

func _ready():
	card1.connect("button_up", self, "show_card", [card1])
	card2.connect("button_up", self, "show_card", [card2])
	card3.connect("button_up", self, "show_card", [card3])
	card4.connect("button_up", self, "show_card", [card4])
	card5.connect("button_up", self, "show_card", [card5])

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		if len(hidden_cards) <= 0:
			visible = false

func PopUp(chest_name, gold, cash, cards):
	# TODO: Modify chest img according to chest_name
	gold_label.text = "+%d" % gold
	cash_label.text = "+%d" % cash
	var i = 1
	for name in cards:
		var card = get("card%d" % i)
		var card_item = card.get_node("Item")
		card_item.Invalidate(data.NewCard(user.Cards[name]))
		hidden_cards.append(card)
		i += 1
	open_anim.play("open%d" % len(cards))
	visible = true
	
func show_card(card):
	var show_anim = card.get_node("AnimationPlayer")
	if open_anim.is_playing() or show_anim.is_playing():
		return
	if not hidden_cards.has(card):
		return
	show_anim.play("show")
	yield(show_anim, "animation_finished")
	hidden_cards.erase(card)
