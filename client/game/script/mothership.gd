extends Node2D

var game
var player
var show_anim_finished = false

func init(game, player, knights):
	self.game = game
	self.player = player
	var positions = [stat.Center, stat.Left, stat.Right]
	for i in range(len(positions)):
		var name = knights[i].Name
		var pos = positions[i]
		var node = $Unit.get_resource(name).instance()
		var deck = get_node("Nodes/Deck/%s/Position/Unit" % pos)
		node.InitDummy(0, 0, game, player, deck.global_rotation)
		deck.add_child(node)
		node.get_node("AnimationPlayer").play("show")
	$Ship.play("show")
	yield($Ship, "animation_finished")
	show_anim_finished = true
	remove_dummy_and_show_knights()
	if player.color == "Blue":
		$AnimLeft.play("deck_on")
		$AnimRight.play("deck_on")

func remove_dummy_and_show_knights():
	for id in player.knightIds:
		var knight = game.FindUnit(id)
		knight.visible = true
	var positions = [stat.Center, stat.Left, stat.Right]
	for i in range(len(positions)):
		var pos = positions[i]
		for child in get_node("Nodes/Deck/%s/Position/Unit" % pos).get_children():
			child.queue_free()

func partial_destroy(side):
	get_node("Anim%s" % side).play("partial_destroy")

func destroy(side):
	get_node("Anim%s" % side).play("destroy")