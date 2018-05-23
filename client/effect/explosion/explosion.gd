extends Node2D

func _ready():
	self.position += Vector2(60, 96)
	yield($AnimationPlayer, "animation_finished")
	queue_free()