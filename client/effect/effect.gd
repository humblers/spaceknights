extends AnimatedSprite

var size

func _ready():
	play(size)

func initialize(pos, _size):
	set_pos(pos)
	size = _size
	connect("finished", self, "on_finished")

func on_finished():
	queue_free()