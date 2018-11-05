extends Node2D

var Name
var init_pos = position
var offset
var pressed = false

onready var game = get_node("../../..")
onready var top = get_node("../../Top").position.y
onready var bottom = get_node("../../Bottom").position.y
onready var tile = get_node("../../Tile")
onready var battle_field = get_node("../../BattleField")

func _ready():
	$Button.connect("gui_input", self, "_handle_input")

func _handle_input(ev):
	if ev is InputEventMouseMotion and pressed:
		ev = get_node("../..").make_input_local(ev)
		var pos = ev.global_position
		if pos.y < bottom:
			var ratio = (bottom - pos.y) / (bottom - top)
			var s = lerp(1, 0, clamp(ratio, 0, 1))
			$Scalable.scale = Vector2(s, s)
		$Scalable.global_position = pos - (offset * scale)

		if pos.y < top:
			var map_pos = battle_field.get_local_mouse_position()
			update_cursor(int(map_pos.x), int(map_pos.y))
			$Cursor.visible = true
		else:
			$Cursor.visible = false
		
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			tile.ShowArea(true)
			ev = make_input_local(ev)
			offset = ev.global_position
		else:
			tile.Hide()
			$Scalable.position = init_pos
			$Scalable.scale = Vector2(1, 1)

func update_cursor(x, y):
	var card = stat.cards[Name]
	var unit = stat.units[card.Unit]
	var tile = game.TileFromPos(x, y)
	var minTileY = game.Map().MinTileYOnBot()
	var maxTileY = game.Map().TileNumY() - 1
	tile[1] = int(clamp(tile[1], minTileY, maxTileY))
	var res = avoid_occupied_tiles(tile[0], tile[1], 1, 1, minTileY, maxTileY)
	if res[1] == null:
		var tr = res[0]
		tile[0] = (tr.l + tr.r) / 2
		tile[1] = (tr.t + tr.b) / 2
	else:
		print(res[1])	# error
	var pos = game.PosFromTile(tile[0], tile[1])
	$Cursor.global_position = Vector2(40 + pos[0], 60 + pos[1])

func avoid_occupied_tiles(x, y, w, h, minTop, maxBot, counter=0):
	var shifted = []
	# left
	if x-w/2-counter >= 0:
		shifted.append({"t":y-h/2, "b":y+h/2, "l":x-w/2-counter, "r":x+w/2-counter})
	# right
	if x+w/2+counter <= game.Map().TileNumX() - 1:
		shifted.append({"t":y-h/2, "b":y+h/2, "l":x-w/2+counter, "r":x+w/2+counter})
	# bottom
	if y+h/2+counter <= maxBot:
		shifted.append({"t":y-h/2+counter, "b":y+h/2+counter, "l":x-w/2, "r":x+w/2})
	# top
	if y-h/2-counter >= minTop:
		shifted.append({"t":y-h/2-counter, "b":y+h/2-counter, "l":x-w/2, "r":x+w/2})
	var candidates = []
	for tr in shifted:
		if tr.t < minTop || tr.b > maxBot || tr.l < 0 || tr.r > game.Map().TileNumX() - 1:
			continue
		candidates.append(tr)
	if len(candidates) == 0:
		return [null, "can't placed"]
	for tr in candidates:
		var intersect = false
		for occupied in game.OccupiedTiles().keys():
			if game.intersect_tilerect(occupied, tr):
				intersect = true
				break
		if not intersect:
			return [tr, null]
	counter += 1
	return avoid_occupied_tiles(x, y, w, h, minTop, maxBot, counter)

func add_unit(node):
	var card = stat.cards[Name]
	var name = card["Unit"]
	var count = card["Count"]
	var offsetX = card["OffsetX"]
	var offsetY = card["OffsetY"]
	for i in count:
		var unit = $Resource/Unit.get_resource(name).instance()
		unit.position = Vector2(offsetX[i], offsetY[i])
		unit.modulate = Color(1.0, 1.0, 1.0, 0.5)
		node.add_child(unit)

func Set(name, player_energy = 0):
	Name = name
	if Name == null or Name == "":
		$Scalable/Icon.visible = false
		$Scalable/NotAvailable.visible = true
		$Scalable/Energy.value = 0
	else:
		add_unit($Dummy)
		add_unit($Cursor)
		$Cursor.visible = false
		$Scalable/Icon.visible = true
		$Scalable/NotAvailable.visible = false
		var cost = stat.cards[Name].Cost
		var ready = player_energy >= cost
		$Scalable/Icon.texture = $Resource/Icon.get_resource(Name)
		$Scalable/Icon/Cost.text = str(cost/1000)
		$Scalable/Icon/NotReady.visible = not ready
		$Scalable/Icon/Ready.visible = ready
		$Scalable/Energy.max_value = cost
		$Scalable/Energy.value = player_energy
