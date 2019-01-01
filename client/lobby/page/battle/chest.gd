extends Button

export(NodePath) onready var can_open = get_node(can_open)
export(NodePath) onready var can_not_open = get_node(can_not_open)
export(NodePath) onready var time_left = get_node(time_left)

var chest

func Set(chest):
	self.chest = chest
	invalidate()

func _ready():
	connect("button_up", self, "open")

func _process(delta):
	invalidate()

func open():
	if chest == null:
		return
	if time_left_sec() <= 0:
		pass
	else:
		pass

func invalidate():
	if chest == null:
		visible = false
		return
	visible = true
	var sec = time_left_sec()
	if sec > 0:
		can_open.visible = false
		can_not_open.visible = true
		var min_ = sec / 60
		time_left.text = "%dh %dm" % [min_/60, min_%60]
	else:
		can_open.visible = true
		can_not_open.visible = false

func time_left_sec():
	assert(chest)
	return OS.get_unix_time() - int(chest.AcquiredAt)