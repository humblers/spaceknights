extends Popup

export(NodePath) onready var btn = get_node(btn)
export(NodePath) onready var message = get_node(message)

func _ready():
	btn.connect("button_up", self, "hide")

func PopUp(message):
	self.message.text = message
	popup_centered()
