extends Button

export(int, 0, 3) var slot = 0
export(String, "Battle", "Feeble") var kind = null

export(NodePath) onready var can_open = get_node(can_open)
export(NodePath) onready var can_not_open = get_node(can_not_open)
export(NodePath) onready var cost_label = get_node(cost_label)
export(NodePath) onready var time_left_label = get_node(time_left_label)
export(NodePath) onready var chest_icon = get_node(chest_icon)

var chest

func Set(chest):
	self.chest = chest
	invalidate()

func _ready():
	assert(kind != null)
	connect("button_up", self, "open")

func _process(delta):
	invalidate()

func invalidate():
	if chest == null:
		visible = false
		return
	visible = true
	chest_icon.Set(chest.Name)
	var time_left = time_left()
	can_open.visible = time_left <= 0
	can_not_open.visible = time_left > 0
	cost_label.text = str(data.RequiredCashForTime(time_left))
	time_left_label.text = static_func.get_time_left_string(time_left)

func time_left():
	assert(chest)
	return chest.AcquiredAt + data.Chests[chest.Name].Duration - OS.get_unix_time()

func open():
	if chest == null:
		return
	event.emit_signal("RequestPoupInContents", event.PopupContentsChestInfo, [chest, kind, slot])