extends Node2D

const DECK_POSITION = "Nodes/Deck/%s/Position/Unit"
const DECK_READY_LIGHT = "Nodes/Deck/%s/Ready%s/SkillReadyC"
const DECK_READY_SIGN = "Nodes/Deck/%s/Ready%s/ReadySign"

func Init(player):
	add_dummy(player)
	$Ship.play("show")
	yield($Ship, "animation_finished")
	remove_dummy(player)

func add_dummy(player):
	for side in player.knightIds:
		var id = player.knightIds[side]
		var name = player.game.FindUnit(id).Name()
		var node = get_tree().current_scene.get_node("Resource/Unit").get_resource(name).instance()
		var deck = get_node(DECK_POSITION % side)
		node.InitDummy(0, 0, player.game, player, deck.global_rotation)
		deck.add_child(node)
		node.get_node("AnimationPlayer").play("show")
		
func remove_dummy(player):
	for side in player.knightIds:
		var id = player.knightIds[side]
		for dummy in get_node(DECK_POSITION % side).get_children():
			dummy.queue_free()
		var knight = player.game.FindUnit(id)
		knight.visible = true

func PartialDestroy(side):
	# delay playing if deck opening anim is not finished
	get_node("Anim%s" % side).queue("partial_destroy")

func Destroy(side):
	get_node("Anim%s" % side).play("destroy")
	
func OpenDeck(side):
	get_node("Anim%s" % side).play("deck_on")

func CloseDeck(side):
	get_node("Anim%s" % side).play("deck_off")

func UpdateDeckReadyState(side, ratio):
	var node = get_node(DECK_READY_LIGHT % [side, side.left(1)])
	node.modulate.a = clamp(ratio, 0, 1)
	node = get_node(DECK_READY_SIGN % [side, side.left(1)])
	node.visible = ratio > 1
