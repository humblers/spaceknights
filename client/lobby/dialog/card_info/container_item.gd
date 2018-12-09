extends Control


export(NodePath) onready var info_root = get_node(info_root)

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var key_label = get_node(key_label)
export(NodePath) onready var value_label = get_node(value_label)

export(NodePath) var sub_popup_btn
export(NodePath) var sub_popup_pos
export(bool) var is_left = true

var sub_info

func _ready():
	if sub_popup_btn != null and sub_popup_pos != null:
		sub_popup_btn = get_node(sub_popup_btn)
		sub_popup_pos = get_node(sub_popup_pos)
		sub_popup_btn.connect("button_up", info_root, "PopUpSub", [self])

func Invalidate(icon_texture, key_text, value_text, sub_info):
	self.sub_info = sub_info
	icon.texture = icon_texture
	static_func.set_text(key_label, key_text)
	static_func.set_text(value_label, value_text)
	if sub_popup_btn != null:
		sub_popup_btn.visible = sub_info != null