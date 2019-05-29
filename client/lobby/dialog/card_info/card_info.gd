extends TextureButton

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
export(NodePath) onready var rarity_panel = get_node(rarity_panel)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var holding_progress = get_node(holding_progress)

export(NodePath) onready var upgrade_label = get_node(upgrade_label)
export(NodePath) onready var upgrade_cost = get_node(upgrade_cost)
export(NodePath) onready var upgrade_btn = get_node(upgrade_btn)

export(NodePath) onready var use_btn = get_node(use_btn)

export(NodePath) onready var icon_resource = get_node(icon_resource)

var card
var unit
var shader_material = preload("res://material/light.tres")

func _ready():
	self.connect("button_up", self, "hide")
	use_btn.connect("button_up", self, "useButtonUp")
	upgrade_btn.connect("button_up", self, "upgradeButtonUp")

func useButtonUp():
	event.emit_signal("PageCardPickedCardItem", card)
	hide()

func isUpgradable():
	if data.Upgrade.IsLevelMax(card.Rarity, card.Level):
		return false
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var coin_cost = data.Upgrade.CoinCostNextLevel(card.Rarity, card.Level)
	return card.Holding >= card_cost and user.Galacticoin >= coin_cost

func upgradeButtonUp():
	if not isUpgradable():
		hide()
		return
	var params = {"Name": card.Name}
	var req = lobby_request.New(
			"/edit/card/upgrade", params)
	var response = yield(req, "Completed")
	if not response[0]:
		event.emit_signal("RequestPopup", event.PopupModalMessage, [response[1].ErrMessage])
		return
	var c = response[1].Card
	c.Name = card.Name
	card = data.NewCard(c)
	user.Cards[card.Name] = card
	user.Galacticoin = response[1].Galacticoin
	event.emit_signal("InvalidateLobby")
	event.emit_signal("RequestDialog", event.DialogCardUpgrade, [card])
	hide()

func PopUp(card, enable_use = false):
	self.card = card
	self.unit = data.units[card.Unit]

	rarity_panel.modulate = get("rarity_panel_%s" % card.Rarity.to_lower())
	use_btn.visible = enable_use
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var coin_cost = data.Upgrade.CoinCostNextLevel(card.Rarity, card.Level)
	upgrade_btn.disabled = card_cost > card.Holding
	holding_progress.max_value = card_cost
	holding_progress.value = card.Holding
	card_name_label.SetText("ID_%s" % card.Name.to_upper())
	info_label.SetText("ID_CARD_INFO_%s" % card.Name)
	rarity_label.SetText("ID_%s" % card.Rarity.to_upper())
	$MainPopup/MainPanel/SubPanel/NinePatchRect/Base.Invalidate(card)
	holding_label.text = "%d/%d" % [card.Holding, card_cost]
	upgrade_cost.text = "%d" % coin_cost
	set_unit_preview(card)

	main_popup.Invalidate(card, unit)
	sub_popup.visible = false
	self.visible = true

func set_unit_preview(card):
	var preview = $MainPopup/MainPanel/SubPanel/NinePatchRect/UnitView
	var position = preview.get_node("UnitPosition")
	for c in position.get_children():
		c.queue_free()
	var path = loading_screen.GetUnitScenePath(card.Unit)
	if card.Type == data.SquireCard:
		for i in card.Count:
			var node = loading_screen.LoadResource(path).instance()
			node.position = Vector2(card.OffsetX[i], card.OffsetY[i])
			node.material = shader_material.duplicate()
			position.add_child(node)
			
		preview.get_node("Symbol/Knight").visible = false
		preview.get_node("Symbol/Squire").visible = true
	else:
		var node = loading_screen.LoadResource(path).instance()
		node.material = shader_material.duplicate()
		position.add_child(node)
		preview.get_node("Symbol/Knight").visible = true
		preview.get_node("Symbol/Squire").visible = false
		
func hide():
	if $SubPopup.visible:
		$SubPopup.visible = false
		return
	self.visible = false

func PopUpSub(pressed):
	sub_popup.Invalidate(card, pressed)
