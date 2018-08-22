tool
extends Node

export(float, 0, 360) var MAIN_LIGHT_ANGLE = 0

var shade_nodes=[]

func _ready():
	print("hello")
	show_shade(self)
	set_process(true)

func _process(delta):
	shade()

func show_shade(node):
	for c in node.get_children():
		if c.name == "Shade":
			var left = c.get_node("Left")
			var right = c.get_node("Right")
			var front = c.get_node("Front")
			var rear = c.get_node("Rear")
			c.move_child(left, 0)
			c.move_child(right, 1)
			c.move_child(front, 2)
			c.move_child(rear, 3)
			left.show()
			right.show()
			front.show()
			rear.show()
			shade_nodes.append(c)
		else:
			show_shade(c)

func shade():
	for n in shade_nodes:
		var angle = MAIN_LIGHT_ANGLE - n.global_rotation_degrees
		var t1 = 1 - clamp(abs(angle_diff(0, angle)) / 90, 0, 1)
		var t2 = 1 - clamp(abs(angle_diff(90, angle)) / 90, 0, 1)
		var t3 = 1 - clamp(abs(angle_diff(180, angle)) / 90, 0, 1)
		var t4 = 1 - clamp(abs(angle_diff(270, angle)) / 90, 0, 1)
		n.get_node("Right").modulate = Color(1, 1, 1, t1)
		n.get_node("Front").modulate = Color(1, 1, 1, t2)
		n.get_node("Left").modulate = Color(1, 1, 1, t3)
		n.get_node("Rear").modulate = Color(1, 1, 1, t4)

func angle_diff(a, b):
	return fposmod((a - b) + 180, 360) - 180
