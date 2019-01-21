extends TextureRect

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var key_label = get_node(key_label)
export(NodePath) onready var value_label = get_node(value_label)
export(NodePath) onready var value_increase_label = get_node(value_increase_label)

func Invalidate(icon_texture, key_text, value_text, value_increase_text):
	icon.texture = icon_texture
	key_label.text = key_text
	value_label.text = value_text
	value_increase_label.text = value_increase_text