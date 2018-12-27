extends Button

export(NodePath) onready var cost_text = get_node(cost_text)
export(NodePath) onready var cash_icon = get_node(cash_icon)
export(NodePath) onready var remain_time = get_node(remain_time)
export(NodePath) onready var timer_icon = get_node(timer_icon)

var chest
var remain_sec

func _ready():
	connect("button_up", self, "open")
	
func Set(chest):
	self.chest = chest
	invalidate()

func open():
	assert(chest)
	if remain_sec <= 0:
		pass
	else:
		pass

func invalidate():
	if chest == null:
		visible = false
		return
	var remaining = remain_sec > 0
	cost_text.visible = remaining
	cash_icon.visible = remaining
	remain_time.visible = remaining
	timer_icon.visible = remaining
	if remaining:
		var remain_min = remain_sec / 60
		remain_time.text = "%dh %dm" % [remain_min/60, remain_min%60]
	
func _process(delta):
	if chest == null:
		return
	remain_sec = OS.get_unix_time() - chest.AcquiredAt
	invalidate()