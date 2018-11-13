extends "res://game/player/player.gd"

const KnightTileX = 4

onready var resources = get_node("../../Resource")
onready var tutor_data = resources.get_node("Tutor").get_resource("tutor_data").new()

var mapTileNumX
var mapTileNumY

var leftRefPoint
var leftRadRange
var rightRefPoint
var rightRadRange

var reservate_cards = {}
var energy_prediction = 0

func Init(playerData, game):
	.Init(playerData, game)
	energy_prediction = energy + ENERGY_PER_FRAME * INPUT_DELAY_STEP
	mapTileNumX = game.Map().TileNumX()
	mapTileNumY = game.Map().TileNumY()
	
	var mw = game.World().ToPixel(game.Map().Width())
	var tl = Vector2(0, 0)
	var tc = Vector2(mw / 2, 0)
	var tr = Vector2(mw, 0)
	var l = Vector2(250, 550)
	var r = Vector2(750, 550)
	leftRefPoint = [game.World().FromPixel(int(l.x)), game.World().FromPixel(int(l.y))]
	leftRadRange = [l.angle_to_point(tl), l.angle_to_point(tc)]
	rightRefPoint = [game.World().FromPixel(int(r.x)), game.World().FromPixel(int(r.y))]
	rightRadRange = [r.angle_to_point(tc), r.angle_to_point(tr)]

func Update():
	if energy < MAX_ENERGY:
		energy_prediction += ENERGY_PER_FRAME
	.Update()
	var analyzed = analyze_opposite()
	var card_candidates = []
	for knightId in knightIds:
		var k = game.FindUnit(knightId)
		if k == null or k.side == "Center":
			continue
		var name = k.Name()
		if reservate_cards.has(name):
			continue
		if k.cast > 0:
			continue
		if decision_knight(name, analyzed):
			card_candidates.append([name, k.level])
	for card in hand:
		var name = card.Name
		if reservate_cards.has(name):
			continue
		if card.Name == "":
			continue
		if decision_squire(name, analyzed):
			card_candidates.append([name, card.Level])
	if len(card_candidates) == 0:
		return
	make_input(elect_card(card_candidates), analyzed)

func Do(action):
	var res = .Do(action)
	reservate_cards.erase(action.Card.Name)
	return res

func decision_knight(knight, analyzed):
	match knight:
		"archengineer", "archsapper":
			if analyzed.total_cost >= 4:
				return true
			return false
		"ironcoffin", "pixieking", "tombstone":
			if analyzed.top.cost <= 5:
				return true
			return false
	return false

func decision_squire(squire, analyzed):
	return true

func elect_card(card_candidates):
	return card_candidates[0]

func make_input(card, analyzed):
	var tile = gen_card_tile(card, analyzed)
	if tile[0] == null or tile[1] == null:
		return
	var input = {
		"Step": game.step + INPUT_DELAY_STEP,
		"Action": {
			"Id": id,
			"Card": {
				"Name": card[0],
				"Level": card[1],
			},
			"TileX": tile[0],
			"TileY": tile[1],
		},
	}
	if game.actions.has(input.Step):
		game.actions[input.Step].append(input.Action)
	else:
		game.actions[input.Step] = [input.Action]
	reservate_cards[input.Action.Card.Name] = true
	energy_prediction -= stat.cards[card[0]].Cost

func gen_card_tile(card, analyzed):
	var x
	var y
	var tw = 1
	var th = 1
	var lr
	var name = card[0]
	# choose target (left /right)
	if analyzed.left.cost > 0 or analyzed.right.cost > 0:
		lr = analyzed.left if analyzed.left.cost > analyzed.right.cost else analyzed.right
	# predict use card location (target's top / bottom)
	if lr != null:
		var target = lr.most_advanced
		var ustat = stat.units[stat.cards[name].Unit]
		var r
		if ustat.has("radius"):
			r = ustat["radius"] + game.World().ToPixel(target.Radius())
		if ustat.has("attackrange"):
			r += ustat["attackrange"]
		if on_top(target):
			var angle = rand_range(0, PI) + PI / 2
			x = game.World().ToPixel(target.PositionX()) - r * cos(angle)
			y = game.World().ToPixel(target.PositionY()) - r * sin(angle)
			var tile = game.TileFromPos(int(x), int(y))
			x = tile[0]
			y = tile[1]
		elif ustat.has("speed"):
			var d = calc_distance(
				[target.PositionX(), target.PositionY()], 
				lr.ref_point, 
				target.Radius())
			var t = scalar.ToInt(scalar.Div(d, target.speed()))
			var away = t * ustat["speed"] + r
			var angle = rand_range(lr.ref_rads[0], lr.ref_rads[1])
			x = game.World().ToPixel(lr.ref_point[0]) - away * cos(angle)
			y = game.World().ToPixel(lr.ref_point[1]) - away * sin(angle)
			if x < 0 or y < 0:
				return [null, null]
			var tile = game.TileFromPos(int(x), int(y))
			x = tile[0]
			y = tile[1]
	# adjust special cases
	match name:
		"ironcoffin", "pixieking", "tombstone":
			var building = stat.units[name]["skill"]["wing"]["unit"]
			tw = stat.units[building]["tilenumx"]
			th = stat.units[building]["tilenumy"]
			if x == null:
				x = tw / 2
				x = randi() % ((mapTileNumX - KnightTileX) / 2 - x)
				x = x if randf() > 0.5 else mapTileNumX - 1 - x
			if y == null:
				y = th / 2
	return avoid_occupied_tiles(x, y, tw, th, 0, mapTileNumY / 2 - 1)

func analyze_opposite():
	var anal = {
		"top": { "cost": 0, "most_advanced": null },
		"bottom": { "cost": 0, "most_advanced": null },
		"left": { 
			"cost": 0, "most_advanced": null, 
			"ref_point": leftRefPoint,
			"ref_rads": leftRadRange,
		},
		"right": { 
			"cost": 0, "most_advanced": null, 
			"ref_point": rightRefPoint,
			"ref_rads": rightRadRange,
		},
		"total_cost": 0,
	}
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == team:
			continue
		var cost = tutor_data.units[u.Name()].Cost
		if cost <= 0:
			continue
		var tb = anal.top if on_top(u) else anal.bottom
		update_analyze_data(tb, u, cost)
		var lr = anal.left if on_left(u) else anal.right
		update_analyze_data(lr, u, cost)
		anal.total_cost += cost
	return anal

func update_analyze_data(dict, u, cost):
	dict.cost += cost
	if dict.most_advanced != null and dict.most_advanced.PositionY() <= u.PositionY():
		return
	dict.most_advanced = u

func on_top(u):
	return u.PositionY() < scalar.Sub(game.Map().top.b, u.Radius())

func on_left(u):
	return u.PositionX() < scalar.Sub(game.Map().centerX, u.Radius())

func calc_distance(from, dest, r, dist = 0):
	var corner = game.Map().FindNextCornerInPath(
		from[0], from[1],
		dest[0], dest[1],
		r)
	var x = scalar.Sub(corner[0], from[0])
	var y = scalar.Sub(corner[1], from[1])
	dist = scalar.Add(dist, vector.LengthSquared(x, y))
	if corner[0] == dest[0] and corner[1] == dest[1]:
		return scalar.Sqrt(dist)
	return calc_distance(corner, dest, r, dist)

func avoid_occupied_tiles(x, y, w, h, minTop, maxBot, counter=0):
	if x == null or y == null or w == null or h == null:
		return [null, null]
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
		return [null, null]
	for tr in candidates:
		var intersect = false
		for occupied in game.OccupiedTiles().keys():
			if game.intersect_tilerect(occupied, tr):
				intersect = true
				break
		if not intersect:
			return [(tr.l + tr.r) / 2, (tr.t + tr.b) / 2]
	counter += 1
	return avoid_occupied_tiles(x, y, w, h, minTop, maxBot, counter)
