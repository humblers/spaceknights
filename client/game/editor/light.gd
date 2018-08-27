tool
extends Node2D

var shader = preload("res://game/script/shader.gd")

func _process(delta):
	var node_to_shade = get_parent()
	if node_to_shade is Node2D:
		var nodes = shader.get_shade_nodes(node_to_shade)
		var angle = rad2deg((global_position - node_to_shade.global_position).angle())
		for n in nodes:
			shader.init(n, true)
			shader.shade(n, angle)
