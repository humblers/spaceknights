extends Node2D

onready var player = get_node("../../Players/Blue")
onready var icon_resource = get_node("../../Resource/Icon")

func _process(delta):
	var name = player.pending[0].Name
	var cost = stat.cards[name].Cost
	var ready = player.energy > cost
	$Icon.texture = icon_resource.get_resource(name)
	$Icon/Cost.text = str(cost/1000)
	$Icon/NotReady.visible = not ready
