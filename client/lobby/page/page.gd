extends CanvasItem

const MODE_NORMAL = "NORMAL"

export(NodePath) onready var lobby = get_node(lobby)
export(NodePath) onready var center_top = get_node(center_top)

export(NodePath) onready var scrollable = get_node(scrollable) if scrollable != null else null

var scroll_min_y
var scroll_max_y

func get_vertical_scrollable_control():
	return scrollable
