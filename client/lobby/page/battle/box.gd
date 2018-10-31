extends TextureButton

func _ready():
	self.connect("button_down", self, "down")
	self.connect("button_up", self, "up")

func down():
	$AnimationPlayer.play("down")

func up():
	$AnimationPlayer.play_backwards("down")