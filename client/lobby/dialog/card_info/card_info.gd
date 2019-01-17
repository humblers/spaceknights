extends Control

const MAX_STAT_COUNT = 10

export(Color) var rarity_panel_common
export(Color) var rarity_panel_rare
export(Color) var rarity_panel_epic
export(Color) var rarity_panel_legendary

export(NodePath) onready var hud = get_node(hud)

export(NodePath) onready var main_popup = get_node(main_popup)
export(NodePath) onready var sub_popup = get_node(sub_popup)

export(NodePath) onready var card_name_label = get_node(card_name_label)
export(NodePath) onready var info_label = get_node(info_label)
export(NodePath) onready var rarity_label = get_node(rarity_label)
export(NodePath) onready var cost_label = get_node(cost_label)
export(NodePath) onready var rarity_panel = get_node(rarity_panel)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var holding_progress = get_node(holding_progress)

export(NodePath) onready var upgrade_label = get_node(upgrade_label)
export(NodePath) onready var upgrade_cost = get_node(upgrade_cost)
export(NodePath) onready var upgrade_btn = get_node(upgrade_btn)

export(NodePath) onready var use_btn = get_node(use_btn)

export(NodePath) onready var icon_resource = get_node(icon_resource)

var card
var unit

func _ready():
	use_btn.connect("button_up", self, "useButtonUp")
	upgrade_btn.connect("button_up", self, "upgradeButtonUp")

func useButtonUp():
	hud.lobby.page_card.set_picked_card(card)
	main_popup.hide()

func isUpgradable():
	if data.Upgrade.IsLevelMax(card.Rarity, card.Level):
		return false
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var coin_cost = data.Upgrade.CoinCostNextLevel(card.Rarity, card.Level)
	return card.Holding >= card_cost and user.Galacticoin >= coin_cost

func upgradeButtonUp():
	if not isUpgradable():
		main_popup.hide()
		return
	var params = {"Name": card.Name}
	var req = hud.lobby.http_manager.new_request(
			HTTPClient.METHOD_POST, "/edit/card/upgrade",
			params)
	var response = yield(req, "response")
	if not response[0]:
		hud.lobby.http_manager.handle_error(response[1].ErrMessage)
		return
	var c = response[1].Card
	user.Cards[card.Name] = c
	user.Galacticoin = response[1].Galacticoin
	c.Name = card.Name
	card = data.NewCard(c)
	hud.lobby.Invalidate()
	hud.cardupgrade_dialog.PopUp(card)
	main_popup.hide()

func PopUp(card, enable_use = false):
	self.card = card
	self.unit = data.units[card.Unit]

	rarity_panel.modulate = get("rarity_panel_%s" % card.Rarity.to_lower())
	icon.texture = hud.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = hud.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	use_btn.visible = enable_use
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var coin_cost = data.Upgrade.CoinCostNextLevel(card.Rarity, card.Level)
	upgrade_btn.disabled = card_cost > card.Holding
	holding_progress.max_value = card_cost
	holding_progress.value = card.Holding
	static_func.set_text(card_name_label, card.Name.to_upper())
	info_label.text = tr("card_info_%s" % card.Name)
	static_func.set_text(rarity_label, card.Rarity)
	static_func.set_text(cost_label, "%d" % (card.Cost / 1000))
	static_func.set_text(level_label, "%02d" % (card.Level + 1))
	static_func.set_text(holding_label, "%d/%d" % [card.Holding, card_cost])
	static_func.set_text(upgrade_cost, "%d" % coin_cost)

	main_popup.Invalidate(card, unit)
	self.visible = true

func Hide():
	self.visible = false

func PopUpSub(pressed):
	sub_popup.Invalidate(card, pressed)