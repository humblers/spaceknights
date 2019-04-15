extends Node

const MODE_NO_SCROLL = "NO_SCROLL"
const MODE_SCROLL_HORIZONTAL = "SCROLL_HORIZONTAL"
const MODE_SCROLL_VERTICAL = "SCROLL_VERTICAL"

const SCROLL_DECISION_PIXEL = 50
const SCROLL_EXTEND_LIMIT = 100

export(NodePath) onready var lobby = get_node(lobby)

export(NodePath) onready var camera = get_node(camera)
export(NodePath) onready var tween = get_node(tween)

var cur_page

var scroll = MODE_NO_SCROLL
var prev_input_pos

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
				var scrollable = cur_page.get_vertical_scrollable_control()
				if scrollable != null:
					if scrollable.rect_position.y > cur_page.scroll_max_y:
						tween.interpolate_property(
								scrollable,
								"rect_position",
								scrollable.rect_position,
								Vector2(scrollable.rect_position.x, cur_page.scroll_max_y),
								0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
						)
						tween.start()
					elif scrollable.rect_position.y < cur_page.scroll_min_y:
						tween.interpolate_property(
								scrollable,
								"rect_position",
								scrollable.rect_position,
								Vector2(scrollable.rect_position.x, cur_page.scroll_min_y),
								0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
						)
						tween.start()
			MODE_SCROLL_HORIZONTAL:
				cur_page = closest_page()
				tween.interpolate_property(
						camera,
						"global_position",
						camera.global_position,
						cur_page.center_top.rect_global_position,
						0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
				)
				tween.start()
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
				var control = cur_page.get_vertical_scrollable_control()
				if control == null:
					continue
				if control.rect_position.y < cur_page.scroll_min_y - SCROLL_EXTEND_LIMIT:
					continue
				if control.rect_position.y > cur_page.scroll_max_y + SCROLL_EXTEND_LIMIT:
					continue
				control.rect_position.y -= d.y
				continue
			MODE_SCROLL_HORIZONTAL:
				camera.position.x += d.x
				continue
			_:
				prev_input_pos = ev.position
				get_tree().set_input_as_handled()

func scroll_mode():
	return scroll

func move_to_page(page):
	var dest_page = lobby.get("page_%s" % page.to_lower())
	tween.interpolate_property(
			camera,
			"global_position",
			camera.global_position,
			dest_page.center_top.rect_global_position,
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	cur_page = dest_page

func closest_page():
	var closest
	var cam_x = camera.global_position.x
	for page in lobby.PAGES:
		var page_node = lobby.get("page_%s" % page.to_lower())
		if closest == null:
			closest = page_node
			continue
		var prev_x = closest.center_top.rect_global_position.x
		var cur_x = page_node.center_top.rect_global_position.x
		if abs(cur_x - cam_x) < abs(prev_x - cam_x):
			closest = page_node
	return closest
