extends BaseButton

export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost_label = get_node(cost_label)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var holding_progress = get_node(holding_progress)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var pressed_btn_guide = get_node(pressed_btn_guide)

export(NodePath) onready var base_animation_player = get_node(base_animation_player)
export(NodePath) onready var animation_player = get_node(animation_player)

var card

func _ready():
	self.connect("button_down", self, "down")
	self.connect("button_up", self, "up")
	self.connect("button_up", page_card, "set_pressed_card", [self])

func Invalidate(card):
	self.card = card
	self.visible = card != null
	if card == null:
		return
	icon.texture = page_card.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = page_card.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	static_func.set_text(cost_label, "%d" % (card.Cost / 1000))
	static_func.set_text(level_label, "%d" % (card.Level + 1))
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	holding_progress.max_value = card_cost
	holding_progress.value = card.Holding
	static_func.set_text(holding_label, "%d/%d" % [card.Holding, card_cost])

func down():
	base_animation_player.play("down")

func up():
	base_animation_player.play_backwards("down")

func changed():
	animation_player.play("changed")

func get_pressed_btn_guide():
	return pressed_btn_guide
