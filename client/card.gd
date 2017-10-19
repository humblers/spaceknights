extends Object

func get_structures_of_unit(card):
	var name
	var offsets
	if card.Name == "archers":
		name = "archer"
		offsets = [ Vector2(1, 0), Vector2(-1, 0) ]
	elif card.Name == "barbarians":
		name = "barbarian"
		offsets = [ Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1) ]
	elif card.Name == "skeletons":
		name = "skeleton"
		offsets = [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ]
	elif card.Name == "speargoblins":
		name = "speargoblin"
		offsets = [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ]
	else:
		name = card.Name
		offsets = [ Vector2(0, 0) ]
	var units = []
	for offset in offsets:
		var unit = {
			"Name" : name,
			"Team" : card.Team,
			"Position" : {
				"X" : card.Position.X + offset.x * global.dict_get(global.UNITS[name], "radius", 0),
				"Y" : card.Position.Y + offset.y * global.dict_get(global.UNITS[name], "radius", 0),
			},
		}
		if unit.Team == "Home":
			unit.Position.Y = global.MAP.height - unit.Position.Y
		units.append(unit)
	return units