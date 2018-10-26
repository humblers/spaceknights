extends Control


func _ready():
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")
	loading_screen.goto_scene("res://lobby/lobby.tscn")
