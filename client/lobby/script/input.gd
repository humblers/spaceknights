extends "res://lobby/script/page_container.gd"

const MODE_NO_SCROLL = "NO_SCROLL"
const MODE_SCROLL_HORIZONTAL = "SCROLL_HORIZONTAL"
const MODE_SCROLL_VERTICAL = "SCROLL_VERTICAL"

const SCROLL_DECISION_PIXEL = 50

onready var camera = $InitialCenter/Camera2D
onready var tween = $Tween

var scroll = MODE_NO_SCROLL
var prev_input_pos

func _ready():
	event.connect("PageSelected", self, "moveToPage")

func _input(ev):
	if ev is InputEventMouseButton:
		if ev.pressed:
			prev_input_pos = ev.position
			return
		prev_input_pos = null
		match scroll:
			MODE_NO_SCROLL:
				return
			MODE_SCROLL_VERTICAL:
				event.emit_signal("VerticalScrollInput", true, 0)
			MODE_SCROLL_HORIZONTAL:
				event.emit_signal("PageSelected", closestPage())
		get_tree().set_input_as_handled()
		get_tree().get_root().gui_release_mouse_focus()
		scroll = MODE_NO_SCROLL

	if ev is InputEventMouseMotion and prev_input_pos != null:
		var d = prev_input_pos - ev.position
		match scroll:
			MODE_NO_SCROLL:
				if abs(d.x) > SCROLL_DECISION_PIXEL:
					scroll = MODE_SCROLL_HORIZONTAL
				elif abs(d.y) > SCROLL_DECISION_PIXEL:
					scroll = MODE_SCROLL_VERTICAL
			MODE_SCROLL_VERTICAL:
				event.emit_signal("VerticalScrollInput", false, d.y)
				continue
			MODE_SCROLL_HORIZONTAL:
				camera.position.x += d.x
				continue
			_:
				prev_input_pos = ev.position
				get_tree().set_input_as_handled()

func scroll_mode():
	return scroll

func moveToPage(page):
	var pos_node = get_node("%s/CameraPosition" % page)
	tween.interpolate_property(
			camera,
			"global_position",
			camera.global_position,
			pos_node.rect_global_position,
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func closestPage():
	var closest_node
	var closest_page
	var cam_x = camera.global_position.x
	for page in ["Battle", "Card"]:
		var pos_node = get_node("%s/CameraPosition" % page)
		if closest_node == null:
			closest_node = pos_node
			closest_page = page
			continue
		var prev_x = closest_node.rect_global_position.x
		var cur_x = pos_node.rect_global_position.x
		if abs(cur_x - cam_x) < abs(prev_x - cam_x):
			closest_node = pos_node
			closest_page = page
	return closest_page