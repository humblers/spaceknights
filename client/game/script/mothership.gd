extends Node2D

var game
var player
var shade_nodes=[]
var shader = preload("res://game/script/custom_shader.gd")
var show_anim_finished = false

func init(game, player, knights):
	self.game = game
	self.player = player
	init_shade(true)	# must init before knight spawn
	var positions = ["Center", "Left", "Right"]
	for i in range(len(positions)):
		var name = knights[i].Name
		var pos = positions[i]
		var node = resource.UNIT[name].instance()
		var deck = get_node("Nodes/Deck/%s/Position/Unit" % pos)
		node.InitDummy(0, 0, game, player, true, deck.global_rotation)
		deck.add_child(node)
		node.get_node("AnimationPlayer").play("show")
	$Ship.play("show")
	yield($Ship, "animation_finished")
	show_anim_finished = true
	remove_dummy_and_show_knights()

func init_shade(enable):
	shade_nodes = shader.get_shade_nodes(self)
	for n in shade_nodes:
		shader.init(n, enable)
	if not enable:
		shade_nodes = []

func _process(delta):
	for n in shade_nodes:
		shader.shade(n, game.MAIN_LIGHT_ANGLE)

func remove_dummy_and_show_knights():
	for id in player.knightIds:
		var knight = game.FindUnit(id)
		knight.visible = true
	var positions = ["Center", "Left", "Right"]
	for i in range(len(positions)):
		var pos = positions[i]
		for child in get_node("Nodes/Deck/%s/Position/Unit" % pos).get_children():
			child.queue_free()

func partial_destroy(side):
	get_node("Anim%s" % side).play("partial_destroy")

func destroy(side):
	get_node("Anim%s" % side).play("destroy")