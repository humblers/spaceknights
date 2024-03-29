extends "res://game/player/player_ui.gd"

onready var opposite_player = get_node("../Blue")
onready var resources = get_node("../../Resource")
onready var tutor_data = resources.get_node("Tutor").get_resource("tutor_data").new()

var tutor_difficulty
var done_bad_decision = false
var decision_delay = 0
var unstable_input_modifier = null

var map_tile_num_x
var map_tile_num_y

var left_dest
var left_deploy_range
var right_dest
var right_deploy_range

var prev_analyzed_data
var cur_analyzed_data

func Init(playerData, game):
	.Init(playerData, game)
	tutor_difficulty = playerData.Difficulty
	map_tile_num_x = game.Map().TileNumX()
	map_tile_num_y = game.Map().TileNumY()
	var map_width = game.World().ToPixel(game.Map().Width())
	left_dest = [
		game.World().FromPixel(int(tutor_data.LEFT_DEST.x)),
		game.World().FromPixel(int(tutor_data.LEFT_DEST.y))]
	right_dest = [
		game.World().FromPixel(int(tutor_data.RIGHT_DEST.x)),
		game.World().FromPixel(int(tutor_data.RIGHT_DEST.y))]
	left_deploy_range = [
		tutor_data.LEFT_DEST.angle_to_point(Vector2(0, 0)),
		tutor_data.LEFT_DEST.angle_to_point(Vector2(map_width / 2, 0))]
	right_deploy_range = [
		tutor_data.RIGHT_DEST.angle_to_point(Vector2(map_width / 2, 0)),
		tutor_data.RIGHT_DEST.angle_to_point(Vector2(map_width, 0))]

func Update():
	.Update()
	prev_analyzed_data = cur_analyzed_data
	cur_analyzed_data = analyze_battlefield()
	if not done_bad_decision:
		done_bad_decision = true
		do_bad(tutor_data.pick_bad_behavior(tutor_difficulty))
		return
	var card_candidates = []
	for card in hand:
		# filtering empty hand
		if card == null:
			continue
		if make_decision_for_use_card(card.Name, card.Level):
			card_candidates.append([card.Name, card.Level, data.SquireCard])
	if len(card_candidates) == 0:
		return
	var card = elect_best_card(card_candidates)
	if card != null and make_input(card):
		done_bad_decision = false

# TODO: remove below functions when this script seperate from player_ui.gd
func removeCardInHand(card, index):
	hand[index] = {}
	pending.append(card)
	emptyIdx.append(index)
func drawCard(index):
	var next = pending.pop_front()
	hand[index] = next
	drawTimer = DRAW_INTERVAL

func analyze_battlefield():
	var d = tutor_data.new_dict_for_analyze()
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		d.unit_positions[u.Id()] = [u.PositionX(), u.PositionY()]
		var cost = tutor_data.units[u.Name()].Cost
		if cost <= 0:
			continue
		var t = d[u.Team()]
		t.total_cost += cost
		var loc = "%s_%s" % ["top" if on_top(u) else "bot", "left" if on_left(u) else "right"]
		t[loc].cost += cost
		if t[loc].front_unit != null and t[loc].front_unit.PositionY() < u.PositionY():
			continue
		t[loc].front_unit = u
	return d

func on_top(u):
	return u.PositionY() < scalar.Sub(game.Map().top.b, u.Radius())

func on_left(u):
	return u.PositionX() < scalar.Sub(game.Map().centerX, u.Radius())

func make_decision_for_use_card(card, level):
	var cost = data.cards[card].Cost
	if cost > energy:
		return false
	var opposite = cur_analyzed_data[opposite_player.Team()]
	if opposite.total_cost < 1:
		return false
	match card:
		"archengineer", "archsapper", "buran":
			if opposite.total_cost < tutor_data.DEFENSE_TYPE_BUILDING_DECISON_COST:
				return false
			var building = data.units[card]["skill"]["wing"]["unit"]
			var tw = data.units[building]["tilenumx"]
			var th = data.units[building]["tilenumy"]
			var x = map_tile_num_x / 2
			var lcost = opposite["top_left"].cost + opposite["bot_left"].cost
			var rcost = opposite["top_right"].cost + opposite["bot_right"].cost
			if lcost > rcost:
				x -= 1
			var y = map_tile_num_y / 2 / 2
			var tr = game.NewTileRect(x, y, tw, th)
			cur_analyzed_data[card] = FindUnoccupiedTileRect(tr, game.Map().TileNumY())
			return true
		"ironcoffin", "pixieking", "tombstone":
			if opposite.top_left.cost + opposite.top_right.cost > tutor_data.SPAWN_TYPE_BUILDING_DECISION_COST:
				return false
			var building = data.units[card]["skill"]["wing"]["unit"]
			var tw = data.units[building]["tilenumx"]
			var th = data.units[building]["tilenumy"]
			var x = tw / 2
			x = randi() % (map_tile_num_x / 2 - x)
			x = x if randf() > 0.5 else map_tile_num_x - 1 - x
			var y = th / 2
			var tr = game.NewTileRect(x, y, tw, th)
			cur_analyzed_data[card] = FindUnoccupiedTileRect(tr, game.Map().TileNumY())
			return true
		"judge", "legion", "valkyrie":
			if opposite.total_cost <= cost:
				return false
			return find_out_whether_to_use_area_skill(
				card,
				level,
				"value_of_instant_damage_skill",
				tutor_data.INSTANT_DAMAGE_SKILL_VALUE_MIN)
		"frost":
			var tb = "top" if opposite["top_left"].cost + opposite["top_right"].cost > 0 else "bot"
			var lr = "left" if opposite["%s_left" % [tb]].cost > opposite["%s_right" % [tb]].cost else "right"
			var extra = cur_analyzed_data[team]["%s_%s" % [tb, lr]].cost
			if tb == "top":
				extra += energy - cost
			if extra >= tutor_data.FREEZE_COMBINATION_REQUIRED_ENERGY:
				return find_out_whether_to_use_area_skill(
					card,
					level,
					"value_of_freeze_skill",
					tutor_data.FREEZE_SKILL_VALUE_MIN)
			return false
		"astra", "lancer":
			if opposite.total_cost <= cost:
				return false
			return find_out_whether_to_use_area_skill(
				card,
				level,
				"value_of_dot_damage_skill",
				tutor_data.DOT_DAMAGE_SKILL_VALUE_MIN)
		_:
			return true
	return false

func elect_best_card(card_candidates):
	var best
	var energy_cap = energy + tutor_data.DONOT_BE_LESS_THAN_OPPISITE_ENERGY
	var opposite_spends = cur_analyzed_data[opposite_player.Team()].total_cost
	for card in card_candidates:
		var cost = data.cards[card[0]].Cost
		if energy_cap - cost < opposite_player.energy:
			continue
		if best != null:
			if best[2] == data.KnightCard and card[2] == data.SquireCard:
				continue
			var d = abs(opposite_spends - data.cards[best[0]].Cost)
			if d < abs(opposite_spends - cost):
				continue
		best = card
	return best

func make_input(card):
	var name = card[0]
	var tr = cur_analyzed_data[name] if cur_analyzed_data.has(name) else find_out_where_to_use_squire(card)
	if tr == null or tr.x == null or tr.y == null:
		return false
	if decision_delay > 0:
		decision_delay -= 1
		return false
	if unstable_input_modifier != null:
		tr.x += unstable_input_modifier[0]
		tr.y += unstable_input_modifier[1]
		unstable_input_modifier = null
	var input = {
		"Step": game.step + 1,
		"Action": {
			"Id": id,
			"Card": {
				"Name": name,
				"Level": card[1],
			},
			"TileX": tr.x,
			"TileY": tr.y,
		},
	}
	if game.actions.has(input.Step):
		game.actions[input.Step].append(input.Action)
	else:
		game.actions[input.Step] = [input.Action]
	return true

func find_out_whether_to_use_area_skill(knight, level, value_func, min_val):
	var skill = data.units[knight]["skill"]["wing"]
	var skill_shape
	var range_x
	var range_y
	if skill.has("radius"):
		skill_shape = "circle"
		range_x = skill["radius"]
		range_y = skill["radius"]
	if skill.has("width") and skill.has("height"):
		skill_shape = "box"
		range_x = skill["width"]
		range_y = skill["height"]
	assert(skill_shape != null)
	var delay = skill["start"] if knight == "astra" else skill["precastdelay"]
	var dt = scalar.Div(scalar.FromInt(delay), scalar.FromInt(10))
	var potentials = []
	var tiles = {}
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == team:
			continue
		if not prev_analyzed_data.unit_positions.has(u.Id()):
			continue
		var prev_pos = prev_analyzed_data.unit_positions[u.Id()]
		var vel_x = scalar.Mul(scalar.Sub(u.PositionX(), prev_pos[0]), scalar.FromInt(10))
		var vel_y = scalar.Mul(scalar.Sub(u.PositionY(), prev_pos[1]), scalar.FromInt(10))
		var pos_x = scalar.Add(u.PositionX(), scalar.Mul(vel_x, dt))
		var pos_y = scalar.Add(u.PositionY(), scalar.Mul(vel_y, dt))
		var potential_pos = Vector2(game.World().ToPixel(pos_x), game.World().ToPixel(pos_y))
		var ur = game.World().ToPixel(u.Radius())
		var v = tutor_data.call(value_func, u, skill, level)
		potentials.append({"pos": potential_pos, "r": ur, "v":v})
		var min_x = potential_pos.x - range_x - ur
		var max_x = potential_pos.x + range_x + ur
		var min_y = potential_pos.y - range_y - ur
		var max_y = potential_pos.y + range_y + ur
		var tile_tl = game.TileFromPos(int(min_x), int(min_y))
		var tile_br = game.TileFromPos(int(max_x), int(max_y))
		for i in range(tile_tl[0], tile_br[0]):
			for j in range(tile_tl[1], tile_br[1]):
				tiles[Vector2(i, j)] = 0
	var best = {"tile": null, "val": 0}
	for tile in tiles:
		var val = 0
		var pos_arr = game.PosFromTile(tile.x, tile.y)
		var cast_pos = Vector2(pos_arr[0], pos_arr[1])
		if knight == "astra":
			cast_pos.y += - range_y if team == "Blue" else range_y
		for p in potentials:
			var overlap = false
			if skill_shape == "box":
				overlap = box_vs_circle_in_pixel(cast_pos, Vector2(range_x, range_y), p["pos"], p["r"])
			elif skill_shape == "circle":
				var ls = (cast_pos - p["pos"]).length_squared()
				var r = skill["radius"] + p["r"]
				if ls < r * r:
					overlap = true
			if overlap:
				val += p["v"]
		if best.tile != null and best.val > val:
			continue
		best = {"tile":tile, "val":val}
	if best.val > min_val:
		cur_analyzed_data[knight] = game.NewTileRect(best.tile[0], best.tile[1], 1, 1)
		return true
	return false

func find_out_where_to_use_squire(card):
	var opposite = cur_analyzed_data[opposite_player.Team()]
	var lcost = opposite["top_left"].cost + opposite["bot_left"].cost
	var rcost = opposite["top_right"].cost + opposite["bot_right"].cost
	var x
	var y
	var name = card[0]
	var lr = "left" if lcost > rcost else "right"
	var tb = "top" if opposite["top_%s" % [lr]].front_unit != null else "bot"
	var front_unit = opposite["%s_%s" % [tb, lr]].front_unit
	var udata = data.units[data.cards[name].Unit]
	var range_
	if udata.has("radius"):
		range_ = udata["radius"] + game.World().ToPixel(front_unit.Radius())
	if udata.has("attackrange"):
		range_ += udata["attackrange"]
	if tb == "top":
		var angle = rand_range(0, PI)
		angle = angle + PI / 2 if lr == "left" else angle - PI / 2
		x = game.World().ToPixel(front_unit.PositionX()) - range_ * cos(angle)
		y = game.World().ToPixel(front_unit.PositionY()) - range_ * sin(angle)
		var tile = game.TileFromPos(int(x), int(y))
		x = tile[0]
		y = tile[1]
	elif data.units[front_unit.Name()].has("speed") and udata.has("speed"):
		var dest = left_dest if lr == "left" else right_dest
		var deploy_range = left_deploy_range if lr == "left" else right_deploy_range
		var d = calc_distance(
			[front_unit.PositionX(), front_unit.PositionY()],
			dest,
			front_unit.Radius())
		var t = scalar.ToInt(scalar.Div(d, front_unit.speed()))
		var away = t * udata["speed"] + range_
		var angle = rand_range(deploy_range[0], deploy_range[1])
		x = game.World().ToPixel(dest[0]) - away * cos(angle)
		y = game.World().ToPixel(dest[1]) - away * sin(angle)
		if x < 0 or y < 0:
			return null
		var tile = game.TileFromPos(int(x), int(y))
		x = tile[0]
		y = tile[1]
	if x == null or y == null:
		return null
	var tr = game.NewTileRect(x, y, 1, 1)
	return FindUnoccupiedTileRect(tr, game.Map().TileNumY())

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

func box_vs_circle_in_pixel(rect_center, rect_size, circle_center, circle_rad):
	var relPos = circle_center - rect_center
	var closest = relPos
	closest.x = clamp(closest.x, -rect_size.x, rect_size.x)
	closest.y = clamp(closest.y, -rect_size.y, rect_size.y)
	if relPos.x == closest.x and relPos.y == closest.y:
		return true
	var normal = relPos - closest
	var d = normal.length_squared()
	if d > circle_rad * circle_rad:
		return false
	return true

func do_bad(behavior):
	match behavior:
		tutor_data.DECISION_DELAY:
			decision_delay = tutor_data.DECISION_DELAY_STEP_COUNT
		tutor_data.UNSTABLE_INPUT:
			unstable_input_modifier = [
				tutor_data.rand_unstable_input(),
				tutor_data.rand_unstable_input(),
			]
		tutor_data.USE_CARD_IMMEDIATELY:
			var cards = []
			for card in hand:
				if card == null:
					continue
				cards.append(card)
			var card = cards[randi() % len(cards)]
			var input = {
				"Step": game.step + 1,
				"Action": {
					"Id": id,
					"Card": {
						"Name": card.Name,
						"Level": card.Level,
					},
					"TileX": randi() % map_tile_num_x,
					"TileY": randi() % (map_tile_num_y / 2 - 1),
				},
			}
			if game.actions.has(input.Step):
				game.actions[input.Step].append(input.Action)
			else:
				game.actions[input.Step] = [input.Action]
