extends Control

export(NodePath) onready var card_info = get_node(card_info)

export(NodePath) onready var icon = get_node(icon)

export(NodePath) onready var skill_popup_btn
export(NodePath) onready var skill_popup_pos

func _ready():
	if skill_popup_btn != null and skill_popup_pos != null:
		skill_popup_btn = get_node(skill_popup_btn)
		skill_popup_pos = get_node(skill_popup_pos)
		skill_popup_btn.connect("button_up", card_info, "popup_sub", [skill_popup_pos])