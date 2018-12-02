extends Node2D

const DECK_PATH = "Nodes/Deck/%s/Position/Unit"

func Init(player):
	add_dummy(player)
	$Ship.play("show")
	yield($Ship, "animation_finished")
	remove_dummy(player)
	
	# TODO: only enable deck on knight card in hand
	if player.color == "Blue":
		$AnimLeft.play("deck_on")
		$AnimRight.play("deck_on")

func add_dummy(player):
	for side in player.knightIds:
		var id = player.knightIds[side]
		var name = player.game.FindUnit(id).Name()
		var node = $Unit.get_resource(name).instance()
		var deck = get_node(DECK_PATH % side)
		node.InitDummy(0, 0, player.game, player, deck.global_rotation)
		deck.add_child(node)
		node.get_node("AnimationPlayer").play("show")
		
func remove_dummy(player):
	for side in player.knightIds:
		var id = player.knightIds[side]
		for dummy in get_node(DECK_PATH % side).get_children():
			dummy.queue_free()
		var knight = player.game.FindUnit(id)
		knight.visible = true

func PartialDestroy(side):
	get_node("Anim%s" % side).play("partial_destroy")

func Destroy(side):
	get_node("Anim%s" % side).play("destroy")