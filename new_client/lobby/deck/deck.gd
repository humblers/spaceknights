extends Control

var unit_pool = []
var units_picked = []

func _ready():
	for name in global.CARDS:
		if global.CARDS[name].type != "spell":
			unit_pool.append(name)

	for child in $Units.get_children():
		child.get_node("Label/Left").connect("pressed", self, "rotate_unit", [child, true])
		child.get_node("Label/Right").connect("pressed", self, "rotate_unit", [child, false])
	$Shuffle.connect("pressed", self, "repick_units")
	repick_units()

func get_selected_units():
	var units = []
	for index in units_picked:
		units.append(unit_pool[index])
	return units

func get_selected_knights():
	var selects = []
	for child in $Knights.get_children():
		selects.append(child.get_node("Label").text.to_lower())
	return selects

func repick_units():
	units_picked = []
	while true:
		var n = randi() % unit_pool.size()
		if units_picked.find(n) == -1:
			units_picked.append(n)
		if units_picked.size() >= 5:
			break
	invalidate_cards_ui()

func invalidate_cards_ui():
	var childs = $Units.get_children()
	for i in range(childs.size()):
		update_unit(childs[i], units_picked[i])

func rotate_unit(node, is_left):
	var next = int(node.name)
	while true:
		next += -1 if is_left else 1
		if next < 0:
			next = unit_pool.size() - 1
		elif next >= unit_pool.size():
			next = 0
		if units_picked.find(next) == -1:
			break
	units_picked.erase(int(node.name))
	units_picked.append(next)
	update_unit(node, next)

func update_unit(node, unit_index):
	var card = unit_pool[unit_index]
	node.name = str(unit_index)
	node.get_node("Label").text = ""
	node.get_node("Label").rect_size.x = 0
	node.get_node("Label").text = card.to_upper()

	for child in node.get_node("IconPosition").get_children():
		child.queue_free()
	var data = global.CARDS[card]
	var uname = data.unitname if data.has("unitname") else card
	var unit = resource.unit[uname].instance()
	unit.initialize({
		"Name" : uname,
		"Team" : global.team,
		"Position" : { "X" : 0, "Y" : 0, },
	})
	node.get_node("IconPosition").add_child(unit)
	unit.transform_to_ui_node()