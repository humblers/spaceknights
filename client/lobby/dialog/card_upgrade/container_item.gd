extends TextureRect

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var key_label = get_node(key_label)
export(NodePath) onready var value_label = get_node(value_label)
export(NodePath) onready var value_increase_label = get_node(value_increase_label)

func Invalidate(icon_texture, key_text, value_text, value_increase_text):
	icon.texture = icon_texture
	static_func.set_text(key_label, key_text)
	static_func.set_text(value_label, value_text)
	static_func.set_text(value_increase_label, value_increase_text)