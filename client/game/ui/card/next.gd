extends MarginContainer

func Set(name, ready):
	var cost = stat.cards[name].Cost
	$Base/Icon.texture = $ResourcePreloader.get_resource(name)
	$Base/Icon/Cost.text = str(cost/1000)
	$Base/Icon/NotReady.visible = not ready
