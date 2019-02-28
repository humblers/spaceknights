extends Popup

onready var ok_button = $VBoxContainer/HBoxContainer/OK
onready var cancel_button = $VBoxContainer/HBoxContainer/Cancel
onready var message_label = $VBoxContainer/Control/Label

signal modal_confirmed(ok)

func _ready():
	ok_button.connect("button_up", self, "ok")
	cancel_button.connect("button_up", self, "cancel")

func PopUp(message_id):
	assert(self.visible == false)
	message_label.SetText(message_id)
	popup()

func ok():
	emit_signal("modal_confirmed", true)
	hide()

func cancel():
	emit_signal("modal_confirmed", false)
	hide()