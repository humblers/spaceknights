extends AnimatedSprite

var a_name

func _ready():
	play(a_name)
	yield(self, "animation_finished")
	queue_free()

func initialize(name, pos):
	a_name = name
	self.position = pos