extends Node2D

var pos_node

func _ready():
	set_process(true)

func _process(delta):
	self.global_position = pos_node.global_position + Vector2(60, 96)
	self.global_rotation = pos_node.global_rotation

func set_pos_node(node):
	self.pos_node = node

func delete():
	set_process(false)
	queue_free()