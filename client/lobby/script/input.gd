extends "res://lobby/script/page_container.gd"

const MODE_NO_SCROLL = "NO_SCROLL"
const MODE_SCROLL_HORIZONTAL = "SCROLL_HORIZONTAL"
const MODE_SCROLL_VERTICAL = "SCROLL_VERTICAL"

const SCROLL_DECISION_PIXEL = 50
const MAX_SWIPE_INTERVAL = 300	# msec
const MIN_SWIPE_SPEED = 1 # pixels per msec

onready var camera = $InitialCenter/Camera2D
onready var tween = $Tween

var scroll = MODE_NO_SCROLL
var prev_input_pos
var init_input_pos
var init_input_time
var current_page = "Battle"

func _ready():
	event.connect("PageSelected", self, "moveToPage")

func page_from_index(idx):
	return event.Pages[idx]
	
func index_from_page(page):
	return PAGES[page] + len(PAGES)/2
	
func _input(ev):
	if ev is InputEventMouseButton:
		if ev.pressed:
			prev_input_pos = ev.position
			init_input_pos = ev.position
			init_input_time = OS.get_system_time_msecs()
			return
		prev_input_pos = null
		match scroll:
			MODE_NO_SCROLL:
				return
			MODE_SCROLL_VERTICAL:
				event.emit_signal("VerticalScrollInput", true, 0)
			MODE_SCROLL_HORIZONTAL:
				var to = closestPage()
				var idx = index_from_page(current_page)
				if idx > 0 and idx < len(event.Pages) - 1:
					var elapsed = OS.get_system_time_msecs() - init_input_time
					var vel_x = (init_input_pos.x - ev.position.x) / elapsed
					if elapsed < MAX_SWIPE_INTERVAL and abs(vel_x) > MIN_SWIPE_SPEED:
						to = page_from_index(idx + 1) if vel_x > 0 else page_from_index(idx - 1)
				event.emit_signal("PageSelected", to)
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
	current_page = page
	
func closestPage():
	var closest_node
	var closest_page
	var cam_x = camera.global_position.x
	for page in event.Pages:
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