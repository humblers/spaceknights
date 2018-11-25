extends "res://lobby/page/page.gd"

const SCROLL_DECISION_PIXEL = 50

var prev_position

onready var pages = get_parent().get_node("Pages")
onready var cur_page = pages.get_node("Battle")
onready var scroll = MODE_NO_SCROLL

func _input(ev):
	if ev is InputEventMouseButton:
		if ev.pressed:
			prev_position = ev.position
			return
		prev_position = null
		match scroll:
			MODE_NO_SCROLL:
				return
			MODE_SCROLL_VERTICAL:
				var scrollable = cur_page.get_vertical_scrollable_control()
				if scrollable != null:
					if scrollable.rect_position.y > cur_page.scroll_max_y:
						$Tween.interpolate_property(
								scrollable,
								"rect_position",
								scrollable.rect_position,
								Vector2(scrollable.rect_position.x, cur_page.scroll_max_y),
								0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
						)
						$Tween.start()
					elif scrollable.rect_position.y < cur_page.scroll_min_y:
						$Tween.interpolate_property(
								scrollable,
								"rect_position",
								scrollable.rect_position,
								Vector2(scrollable.rect_position.x, cur_page.scroll_min_y),
								0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
						)
						$Tween.start()
			MODE_SCROLL_HORIZONTAL:
				cur_page = closest_page()
				$Tween.interpolate_property(
						$Camera2D,
						"global_position",
						$Camera2D.global_position,
						cur_page.get_node("CenterTop").rect_global_position,
						0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
				)
				$Tween.start()
		get_tree().set_input_as_handled()
		scroll = MODE_NO_SCROLL

	if ev is InputEventMouseMotion and prev_position != null:
		var d = prev_position - ev.position
		match scroll:
			MODE_NO_SCROLL:
				if abs(d.x) > SCROLL_DECISION_PIXEL:
					scroll = MODE_SCROLL_HORIZONTAL
				elif abs(d.y) > SCROLL_DECISION_PIXEL:
					scroll = MODE_SCROLL_VERTICAL
			MODE_SCROLL_VERTICAL:
				var control = cur_page.get_vertical_scrollable_control()
				if control != null:
					control.rect_position.y -= d.y
				continue
			MODE_SCROLL_HORIZONTAL:
				$Camera2D.position.x += d.x
				continue
			_:
				prev_position = ev.position
				get_tree().set_input_as_handled()

func scroll_mode():
	return scroll

func move_to_page(btn):
	cur_page = pages.get_node(btn.name)
	$Tween.interpolate_property(
			$Camera2D,
			"global_position",
			$Camera2D.global_position,
			cur_page.get_node("CenterTop").rect_global_position,
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func closest_page():
	var closest
	var cam_x = $Camera2D.global_position.x
	for page in pages.get_children():
		if closest == null:
			closest = page
			continue
		var prev_x = closest.get_node("CenterTop").rect_global_position.x
		var cur_x = page.get_node("CenterTop").rect_global_position.x
		if abs(cur_x - cam_x) < abs(prev_x - cam_x):
			closest = page
	return closest