extends BaseButton

export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost_label = get_node(cost_label)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var upgrade_process = get_node(upgrade_process)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var pressed_btn_guide = get_node(pressed_btn_guide)

export(NodePath) onready var base_animation_player = get_node(base_animation_player)
export(NodePath) onready var animation_player = get_node(animation_player)

var card
var anim

func _ready():
	self.connect("button_down", self, "down")
	self.connect("button_up", self, "up")

func Invalidate(card):
	self.card = card
	self.visible = card != null
	if card == null:
		return
	icon.texture = page_card.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = page_card.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	cost_label.text = "%d" % (card.Cost / 1000)
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity] + 1)
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	upgrade_process.max_value = card_cost
	upgrade_process.value = card.Holding
	holding_label.text = "%d/%d" % [card.Holding, card_cost]
	if isUpgradable():
		upgrade_process.set_self_modulate(Color(0, 1, 0.553,1))
		upgrade_process.get_node("Active").show()
		upgrade_process.get_node("Active").set_emitting(true)
		upgrade_process.get_node("Inactive").hide()
	else:
		if card.Holding < card_cost:
			upgrade_process.set_self_modulate(Color(0.101, 0.584, 1, 1))
			upgrade_process.get_node("Inactive").set_modulate(Color(0.062, 0.584, 1, 1))
		else:
			upgrade_process.set_self_modulate(Color(0, 1, 0.553,1))
			upgrade_process.get_node("Inactive").set_modulate(Color(0.117, 1, 0.6, 1))
		upgrade_process.get_node("Active").hide()
		upgrade_process.get_node("Active").set_emitting(false)
		upgrade_process.get_node("Inactive").show()

func down():
	base_animation_player.play("down")

func up():
	base_animation_player.play_backwards("down")
	page_card.set_pressed_card(self.card, pressed_btn_guide.global_position)

func changed():
	animation_player.play("changed")

func isUpgradable():
	if data.Upgrade.IsLevelMax(card.Rarity, card.Level):
		return false
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var coin_cost = data.Upgrade.CoinCostNextLevel(card.Rarity, card.Level)
	return card.Holding >= card_cost and user.Galacticoin >= coin_cost
	