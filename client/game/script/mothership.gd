extends Node2D

const DECK_POSITION = "Nodes/Deck/%s/Position/Unit"
const DECK_READY_LIGHT = "Nodes/Deck/%s/Ready%s/SkillReadyC"
const DECK_READY_SIGN = "Nodes/Deck/%s/Ready%s/ReadySign"

export(String, "Blue", "Red") var color = null

func _ready():
	event.connect("%sPlayerInitialized" % String(color), self, "init", [], CONNECT_ONESHOT)
	event.connect("%sMothershipDeckUpdate" % color, self, "updateDeck")
	event.connect("RunwayRotate", self, "runwayRotate")

func init(player):
	event.connect("%sKnightDead" % color, self, "destroy")
	event.connect("%sKnightHalfDamaged" % color, self, "partialDestroy")
	add_dummy(player)
	$Ship.play("show")
	yield($Ship, "animation_finished")
	remove_dummy(player)

func add_dummy(player):
	for side in player.knightIds:
		var id = player.knightIds[side]
		var name = player.game.FindUnit(id).Name()
		var path = loading_screen.GetUnitScenePath(name)
		var node = loading_screen.LoadResource(path).instance()
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

func partialDestroy(side):
	# delay playing if deck opening anim is not finished
	get_node("Anim%s" % side).queue("partial_destroy")

func destroy(side):
	get_node("Anim%s" % side).play("destroy")

func updateDeck(side, charging_ratio = 0):
	get_node("Nodes/Deck/%s/Ready/Hologram" % side).value = charging_ratio * 100
	get_node("Anim%s" % side).play("deck_on" if charging_ratio >= 1 else "deck_off")

func runwayRotate(num, angle):
	if color == "Red":
		return
	var side = "L" if num < 3 else "R"
	var runway = get_node("Nodes/Container/GUI/Module/Set/ElixirBar/NextBase/Frame%s/Link2%s/Link1L%d/DeckBaseL%d/Guide" % [ side, side, num, num ])
	if runway:
		runway.set_rotation_degrees(angle)