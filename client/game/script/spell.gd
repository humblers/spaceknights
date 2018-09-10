extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	yield($AnimationPlayer, "animation_finished")
	queue_free()
