extends Node

const MODE_NORMAL = "NORMAL"
const MODE_EDIT_KNIGHT = "EDIT_KNIGHT"
const MODE_EDIT_TROOP = "EDIT_TROOP"
const MODE_NO_SCROLL = "NO_SCROLL"
const MODE_SCROLL_HORIZONTAL = "SCROLL_HORIZONTAL"
const MODE_SCROLL_VERTICAL = "SCROLL_VERTICAL"

export(NodePath) var scrollable

var scroll_min_y
var scroll_max_y

func _ready():
	if scrollable != null:
		scrollable = get_node(scrollable)

func get_vertical_scrollable_control():
	return scrollable