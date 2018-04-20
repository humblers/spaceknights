extends Node2D

var radius = 30
var color = Color(1, 0, 0)

func _draw():
	draw_circle(Vector2(0, 0), radius, color)
