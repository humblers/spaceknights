extends Node2D

func _ready():
	event.connect("FocusAt", self, "focusAt")
	event.connect("FocusOff", self, "focusOff")

func focusAt(global_pos):
	self.global_position = global_pos
	$AnimationPlayer.play("on")

func focusOff():
	$AnimationPlayer.play("off")