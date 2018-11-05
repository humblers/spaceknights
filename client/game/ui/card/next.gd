extends Node2D

func Set(name, ready):
	var cost = stat.cards[name].Cost
	$Icon.texture = $ResourcePreloader.get_resource(name)
	$Icon/Cost.text = str(cost/1000)
	$Icon/NotReady.visible = not ready
