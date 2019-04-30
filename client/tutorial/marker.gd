extends Node2D

func _ready():
	event.connect("MarkAt", self, "markAt")
	event.connect("MarkOff", self, "markOff")

func markAt(global_pos):
	self.global_position = global_pos
	$AnimationPlayer.play("on")

func markOff():
	$AnimationPlayer.play("off")