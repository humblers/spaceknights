extends AnimatedSprite

var name

func _ready():
	play(name)
	yield(self, "finished")
	queue_free()

func initialize(name, pos):
	self.name = name
	set_pos(pos)