extends Node

static func get_shade_nodes(root):
	var nodes = []
	for c in root.get_children():
		if c.name == "Shade":
			nodes.append(c)
		else:
			nodes = nodes + get_shade_nodes(c)
	return nodes

static func init(node, enable):
	var left = node.get_node("Left")
	var right = node.get_node("Right")
	var front = node.get_node("Front")
	var rear = node.get_node("Rear")
	node.move_child(left, 0)
	node.move_child(right, 1)
	node.move_child(front, 2)
	node.move_child(rear, 3)
	left.visible = enable
	right.visible = enable
	front.visible = enable
	rear.visible = enable
	
static func shade(node, light_angle):
	var angle = light_angle - node.global_rotation_degrees
	var t1 = 1 - clamp(abs(angle_diff(0, angle)) / 90, 0, 1)
	var t2 = 1 - clamp(abs(angle_diff(90, angle)) / 90, 0, 1)
	var t3 = 1 - clamp(abs(angle_diff(180, angle)) / 90, 0, 1)
	var t4 = 1 - clamp(abs(angle_diff(270, angle)) / 90, 0, 1)
	node.get_node("Right").modulate = Color(1, 1, 1, t1)
	node.get_node("Rear").modulate = Color(1, 1, 1, t2)
	node.get_node("Left").modulate = Color(1, 1, 1, t3)
	node.get_node("Front").modulate = Color(1, 1, 1, t4)

static func angle_diff(a, b):
	return fposmod((a - b) + 180, 360) - 180
