extends Node2D

var name

func initialize(name, knight_pos):
	self.name = name
	var card = global.CARDS[name]
	var aoe_node = get_node(card.shape)
	aoe_node.show()
	aoe_node.set_scale(global.get_scale(name, aoe_node.get_texture().get_size()))
	set_position(knight_pos)

func set_position(knight_pos):
	var card = global.CARDS[name]
	set_pos(Vector2(knight_pos.x, knight_pos.y - card["range"]))