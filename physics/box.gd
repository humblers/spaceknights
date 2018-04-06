extends Node2D

var width = 400
var height = 40
var color = Color(0, 1, 0)

func _draw():
	draw_rect(Rect2(-width/2, -height/2, width, height), color)
