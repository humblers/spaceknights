extends Control

export(NodePath) onready var card_info = get_node(card_info)

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var key_label = get_node(key_label)
export(NodePath) onready var value_label = get_node(value_label)

export(NodePath) onready var skill_popup_btn
export(NodePath) onready var skill_popup_pos

func _ready():
	if skill_popup_btn != null and skill_popup_pos != null:
		skill_popup_btn = get_node(skill_popup_btn)
		skill_popup_pos = get_node(skill_popup_pos)
		skill_popup_btn.connect("button_up", card_info, "PopupSub", [skill_popup_pos])

func invalidate(icon_texture, label_text, value, sub_info):
	icon.texture = icon_texture
	key_label.text = label_text
#	value_label.text = value
	skill_popup_btn.visible = sub_info != null