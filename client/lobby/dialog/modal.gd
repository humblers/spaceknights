extends Popup

export(NodePath) onready var btn = get_node(btn)
export(NodePath) onready var message = get_node(message)

func _ready():
	event.connect("RequestMessageModal", self, "popUp")
	btn.connect("button_up", self, "hide")

func popUp(message, back_to_company_logo = true):
	self.message.text = message
	popup_centered()
	if back_to_company_logo:
		yield(self, "popup_hide")
		loading_screen.GoToScene("res://company_logo/company_logo.tscn")