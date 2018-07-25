extends PopupPanel

func _ready():
	$TextureButton.connect("pressed", self, "pressed")

func pressed():
	visible = false

func pop(message):
	$Label.text = message
	popup_centered()