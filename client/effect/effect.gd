extends AnimatedSprite

func _ready():
	connect("finished", self, "_on_finished")
	# temporary scale for all unit explosion
	set_scale(Vector2(2.0, 2.0))
	set_frame(0)

func _on_finished():
	queue_free()