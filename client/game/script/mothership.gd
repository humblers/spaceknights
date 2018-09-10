extends Node2D

var animByKnightId = {}

var game
var shade_nodes=[]
var shader = preload("res://game/script/custom_shader.gd")

func init(game, player, knights):
	self.game = game
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

func init_shade(enable):
	shade_nodes = shader.get_shade_nodes(self)
	for n in shade_nodes:
		shader.init(n, enable)
	if not enable:
		shade_nodes = []

func _process(delta):
	for n in shade_nodes:
		shader.shade(n, game.MAIN_LIGHT_ANGLE)

func knights_added(knightIds):
	var positions = ["Center", "Left", "Right"]
	for i in range(len(positions)):
		var id = knightIds[i]
		var pos = positions[i]
		animByKnightId[id] = get_node("Anim%s" % pos)
		for child in get_node("Nodes/Deck/%s/Position/Unit" % pos).get_children():
			child.queue_free()

func partial_destroy(knightId):
	var anim = animByKnightId[knightId]
	if anim.is_playing():
		return
	anim.play("partial_destroy")

func destroy(knightId):
	var anim = animByKnightId[knightId]
	if anim.is_playing() and anim.current_animation == "destroy":
		return
	anim.play("destroy")