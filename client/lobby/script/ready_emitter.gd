extends Node

func _ready():
	emit_signal("ready", self)