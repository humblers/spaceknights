extends TextureButton

export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost_label = get_node(cost_label)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var container = get_node(container)
export(NodePath) onready var main_btn = get_node(main_btn)
export(NodePath) onready var info_btn = get_node(info_btn)
export(NodePath) onready var use_btn = get_node(use_btn)
export(NodePath) onready var upgrade_btn = get_node(upgrade_btn)
export(NodePath) onready var upgrade_cost = get_node(upgrade_cost)

var card

func _ready():
	main_btn.connect("button_up", self, "set_pressed_card", [null])
	use_btn.connect("button_up", self, "useButtonUp")
	info_btn.connect("button_up", self, "pop_card_info")
	upgrade_btn.connect("button_up", self, "pop_card_info")	
	upgrade_btn.hide()
	info_btn.hide()

		

func Invalidate(card):
	self.card = card
	self.visible = card != null
	if card == null:
		return
	use_btn.visible = not user.CardInDeck(card.Name)
	container.rect_size.y = 0 # force downsizing
	icon.texture = page_card.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = page_card.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	cost_label.text = "%d" % (card.Cost / 1000)
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity] + 1)
	
	if isUpgradable():
		info_btn.hide()
		upgrade_btn.show()
	else:
		upgrade_btn.hide()
		info_btn.show()

func useButtonUp():
	page_card.set_picked_card(self.card)

func pop_card_info():
	page_card.lobby.hud.cardinfo_dialog.PopUp(card, not user.CardInDeck(card.Name))
	self.card = null
	page_card.set_pressed_card(null)
	
func isUpgradable():
	if data.Upgrade.IsLevelMax(card.Rarity, card.Level):
		return false
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var coin_cost = data.Upgrade.CoinCostNextLevel(card.Rarity, card.Level)
	upgrade_cost.text = "%d" % coin_cost
	return card.Holding >= card_cost and user.Galacticoin >= coin_cost
