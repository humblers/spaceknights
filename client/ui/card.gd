extends Control

var cur

func update(energy, card):
	var data = global.CARDS[card]
	var cost = data.cost
	update_visible(energy >= cost)
	if cur == card:
		return
	cur = card
	$Over/Cost.text = str(cost / 1000)
	for child in $Icon.get_children():
		child.queue_free()	
	if global.is_spell_card(card):
		var label = Label.new()
		label.set_text(card)
		var font = DynamicFont.new()
		font.font_data = preload("res://font/City Bold Italic.ttf")
		font.size = 32
		label.add_font_override("font", font)
		$Icon.add_child(label)
	else:
		var uname = data.unitname if data.has("unitname") else card
		var node = resource.unit[uname].instance()
		node.initialize({
			"Name" : uname,
			"Team" : global.team,
			"Position" : { "X" : 0, "Y" : 0, },
		})
		$Icon.add_child(node)
		node.transform_to_ui_node()
		node.scale = Vector2(0.8, 0.8)
	
func update_visible(ready):
	$Under/On.visible = ready
	$Over/On.visible = ready
	$Under/Off.visible = not ready
	$Over/Off.visible = not ready