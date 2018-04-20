extends Node2D

export var width = 400
export var height = 40
var color = Color(0, 1, 0)

func _draw():
	draw_rect(Rect2(-width, -height, width * 2, height * 2), color)
