extends Control

export(NodePath) onready var elapsed_label = get_node(elapsed_label)

var elapsed

func _ready():
	set_process(false)

func _process(delta):
	elapsed += delta
	elapsed_label.text = "%d" % elapsed

func Pop():
	self.elapsed = 0
	show_modal()
	visible = true
	set_process(true)

func Hide():
	set_process(false)
	visible = false

func cancel():
	var req = lobby_request.New("/match/cancel")
	var response = yield(req, "Completed")
	if not response[0]:
		event.emit_signal("RequestPopup", event.PopupModalMessage, [response[1].ErrMessage, false])
		return
	Hide()
