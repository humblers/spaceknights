extends Control

const MAX_STAT_COUNT = 10

export(Color) var rarity_panel_common
export(Color) var rarity_panel_rare
export(Color) var rarity_panel_epic
export(Color) var rarity_panel_legendary

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
	get_tree().current_scene.page_card.set_picked_card(card)
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
	var req = lobby_request.New(
			"/edit/card/upgrade", params)
	var response = yield(req, "Completed")
	if not response[0]:
		get_tree().current_scene.HandleError(response[1].ErrMessage)
		return
	var c = response[1].Card
	user.Cards[card.Name] = c
	user.Galacticoin = response[1].Galacticoin
	c.Name = card.Name
	card = data.NewCard(c)
	get_tree().current_scene.Invalidate()
	get_tree().current_scene.hud.cardupgrade_dialog.PopUp(card)
	main_popup.hide()

func PopUp(card, enable_use = false):
	self.card = card
	self.unit = data.units[card.Unit]

	rarity_panel.modulate = get("rarity_panel_%s" % card.Rarity.to_lower())
	icon.texture = get_tree().current_scene.resource_manager.get_card_icon(card.Name)
	frame.texture = get_tree().current_scene.resource_manager.get_card_frame(card.Type, card.Rarity)
	use_btn.visible = enable_use
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var coin_cost = data.Upgrade.CoinCostNextLevel(card.Rarity, card.Level)
	upgrade_btn.disabled = card_cost > card.Holding
	holding_progress.max_value = card_cost
	holding_progress.value = card.Holding
	card_name_label.SetText("ID_%s" % card.Name.to_upper())
	info_label.SetText("ID_CARD_INFO_%s" % card.Name)
	rarity_label.SetText("ID_%s" % card.Rarity.to_upper())
	cost_label.text = "%d" % (card.Cost / 1000)
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity] + 1)
	holding_label.text = "%d/%d" % [card.Holding, card_cost]
	upgrade_cost.text = "%d" % coin_cost

	main_popup.Invalidate(card, unit)
	self.visible = true

func Hide():
	self.visible = false

func PopUpSub(pressed):
	sub_popup.Invalidate(card, pressed)
