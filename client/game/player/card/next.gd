extends Node2D

export(NodePath) onready var icon = get_node(icon)

func Set(card):
	$Icon.texture = icon.get_resource(card.Name)
	$Icon/Energy/Cost.text = str(card.Cost/1000)

func Update(ready):
	$Icon/NotReady.visible = not ready
