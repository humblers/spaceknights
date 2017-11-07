extends Object

func get_structures_of_unit(card):
	var dict = global.CARDS[card.Name]
	var name = card.Name
	var offsets = [ Vector2(0, 0) ]
	if dict.has("unitname"):
		name = dict.unitname
	if dict.has("unitoffsets"):
		offsets = dict.unitoffsets
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