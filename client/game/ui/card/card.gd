extends VBoxContainer

func Set(name, player_energy = 0):
	if name == null or name == "":
		$Base/Icon.visible = false
		$Base/NotAvailable.visible = true
		$Energy.value = 0
	else:
		$Base/Icon.visible = true
		$Base/NotAvailable.visible = false
		var cost = stat.cards[name].Cost
		var ready = player_energy >= cost
		$Base/Icon.texture = $ResourcePreloader.get_resource(name)
		$Base/Icon/Cost.text = str(cost/1000)
		$Base/Icon/NotReady.visible = not ready
		$Base/Icon/Ready.visible = ready
		$Energy.max_value = cost
		$Energy.value = player_energy