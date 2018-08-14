extends Node2D

var animByKnightId = {}

func init(game, player):
	$Ship.play("deafult")
	yield($Ship, "animation_finished")
	$Ship.play("show")

	var knights = player.knightIds
	var positions = ["Left", "Center", "Right"]
	for i in range(len(positions)):
		var id = knights[i]
		var position = positions[i]
		animByKnightId[id] = get_node("Anim%s" % position)

	yield($Ship, "animation_finished")

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