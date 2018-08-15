extends Node2D

var animByKnightId = {}

func init(game, player, knights):
	var positions = ["Left", "Center", "Right"]
	for i in range(len(positions)):
		var name = knights[i].Name
		var pos = positions[i]
		var node = resource.UNIT[name].instance()
		node.InitDummy(0, 0, game, player)
		get_node("Nodes/Deck/%s/Position/Unit" % pos).add_child(node)
		node.get_node("AnimationPlayer").play("show")
	$Ship.play("deafult")
	yield($Ship, "animation_finished")
	$Ship.play("show")

func play(game):
	var anim_len = $Ship.current_animation_length
	var cur_sec = float(game.step) / game.STEP_PER_SEC
	var remain_time = anim_len - cur_sec
	if remain_time < 0:
		return
	$Ship.advance(cur_sec - $Ship.current_animation_position)

func knights_added(knightIds):
	var positions = ["Left", "Center", "Right"]
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