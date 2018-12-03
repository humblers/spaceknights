extends Control

export(Color) var rarity_panel_common
export(Color) var rarity_panel_rare
export(Color) var rarity_panel_epic
export(Color) var rarity_panel_legendary

export(NodePath) onready var hud = get_node(hud)

export(NodePath) onready var main_popup = get_node(main_popup)
export(NodePath) onready var sub_popup = get_node(sub_popup)

export(NodePath) onready var card_name_label = get_node(card_name_label)
export(NodePath) onready var rarity_label = get_node(rarity_label)
export(NodePath) onready var rarity_panel = get_node(rarity_panel)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost = get_node(cost)

export(NodePath) onready var main_stat_container = get_node(main_stat_container)
export(NodePath) onready var sub_stat_container = get_node(sub_stat_container)

var card

func _ready():
	main_popup.connect("popup_hide", self, "popup_hide")

func popup(card):
	self.card = card

	card_name_label.text = card.Name
	rarity_label.text = card.Rarity
	rarity_panel.modulate = get("rarity_panel_%s" % card.Rarity.to_lower())
	icon.texture = hud.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = hud.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	cost.text = "%d" % (card.Cost / 1000)

	self.visible = true
	main_popup.popup()

func popup_hide():
	self.visible = false

func popup_sub(pos_node):
	sub_popup.rect_global_position = pos_node.global_position
	sub_popup.popup()