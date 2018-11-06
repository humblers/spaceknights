extends Node2D

export(String, "Blue", "Red") var color

onready var player = get_node("../../Players/%s" % color)
onready var icon_resource = get_node("../../Resource/Icon")

func _process(delta):
	var name = player.pending[0].Name
	var cost = stat.cards[name].Cost
	$Icon.texture = icon_resource.get_resource(name)
	$Icon/Cost.text = str(cost/1000)
	$Icon/NotReady.visible = player.rollingCounter > 0
