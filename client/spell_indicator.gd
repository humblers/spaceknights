extends Node2D

var name

func initialize(name, knight_pos):
	var card = global.CARDS[name]
	var aoe_node = get_node(card.shape)
	var size = aoe_node.get_texture().get_size()
	aoe_node.show()
	aoe_node.set_scale(Vector2(card.radius*2/size.x, card.radius*2/size.y))
	self.name = name
	set_position(knight_pos)
#	var icon = Sprite.new()
#	icon.set_texture(resource.icon[name].small)
#	icon.set_opacity(0.7)
#	get_node("center").add_child(icon)

func set_position(knight_pos):
	var card = global.CARDS[name]
	set_pos(Vector2(knight_pos.x, knight_pos.y - card["range"]))