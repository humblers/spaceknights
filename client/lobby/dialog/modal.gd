extends Popup

export(NodePath) onready var btn = get_node(btn)
export(NodePath) onready var message = get_node(message)

func _ready():
	btn.connect("button_up", self, "close")

func close():
	visible = false

func pop(message):
	self.message.text = message
	popup_centered()
