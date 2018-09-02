extends Node2D

var animByKnightId = {}
var dummy_anims = []
var default_finished
var opening_finished

var game
var shade_nodes=[]
var shader = preload("res://game/script/shader.gd")

func init(game, player, knights):
	self.game = game
	init_shade(true)	# must init before knight spawn
	var positions = ["Center", "Left", "Right"]
	for i in range(len(positions)):
		var name = knights[i].Name
		var pos = positions[i]
		var node = resource.UNIT[name].instance()
		get_node("Nodes/Deck/%s/Position/Unit" % pos).add_child(node)
		node.InitDummy(0, 0, game, player, true)
		var dummy_anim = node.get_node("AnimationPlayer")
		dummy_anims.append(dummy_anim)
		dummy_anim.play("show")
	$Ship.play("deafult")
	yield($Ship, "animation_finished")
	$Ship.play("show")
	default_finished = true
	yield($Ship, "animation_finished")
	opening_finished = true

func init_shade(enable):
	shade_nodes = shader.get_shade_nodes(self)
	for n in shade_nodes:
		shader.init(n, enable)
	if not enable:
		shade_nodes = []

func _process(delta):
	for n in shade_nodes:
		shader.shade(n, game.MAIN_LIGHT_ANGLE)

func play(game):
	if not default_finished or opening_finished:
		return
	var anim_len = $Ship.current_animation_length
	var cur_sec = float(game.step) / game.STEP_PER_SEC
	var remain_time = anim_len - cur_sec
	if remain_time < 0:
		$Ship.seek(anim_len, true)
		return
	$Ship.advance(cur_sec - $Ship.current_animation_position)
	for anim in dummy_anims:
		anim.advance(cur_sec - anim.current_animation_position)

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