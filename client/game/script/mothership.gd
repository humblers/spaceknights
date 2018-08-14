extends Node2D

var animByKnightId = {}

func init(game, player):
	return
	$Ship.play("deafult")
	yield($Ship, "animation_finished")
	$Ship.play("show")

	var knights = player.knightIds
	var positions = ["Left", "Center", "Right"]
	for i in range(len(positions)):
		var id = knights[i]
		var position = positions[i]
		animByKnightId[id] = get_node("Anim%s" % position)
		var unit = game.FindUnit(id)
		game.get_node("Units").remove_child(unit)
		get_node("Nodes/Deck/%s/Position/Unit" % position).add_child(unit)
		unit.setLayer("NoPhysics")
		unit.position = Vector2(0, 0)
		unit.get_node("AnimationPlayer").play("show")

	yield($Ship, "animation_finished")
	for pos in positions:
		var parent = get_node("Nodes/Deck/%s/Position/Unit" % pos)
		for child in parent.get_children():
			parent.remove_child(child)
			game.get_node("Units").add_child(child)
			child.setLayer("Normal")
			child.SetPosition(child.initPosX, child.initPosY)

func partial_destroy(knightId):
	return
	var anim = animByKnightId[knightId]
	if anim.is_playing():
		return
	anim.play("partial_destroy")

func destroy(knightId):
	return
	var anim = animByKnightId[knightId]
	if anim.is_playing() and anim.current_animation == "destroy":
		return
	anim.play("destroy")