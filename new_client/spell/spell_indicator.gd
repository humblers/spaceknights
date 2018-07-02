extends Node2D

func initialize(name):
	var aoe_node = get_node(global.CARDS[name].shape)
	aoe_node.show()
	aoe_node.set_scale(global.get_scale(name, aoe_node.get_texture().get_size()))