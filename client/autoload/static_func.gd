extends Node

static func draw_circle_arc(canvas_item, center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	for index_point in range(nb_points):
		canvas_item.draw_line(points_arc[index_point], points_arc[index_point + 1], color)

static func cast_float_to_int(parsed_json):
	match typeof(parsed_json):
		TYPE_REAL:
			parsed_json = int(parsed_json)
		TYPE_DICTIONARY:
			for k in parsed_json.keys():
				parsed_json[k] = cast_float_to_int(parsed_json[k])
		TYPE_ARRAY:
			for i in range(parsed_json.size()):
				parsed_json[i] = cast_float_to_int(parsed_json[i])
	return parsed_json

static func get_time_left_string(total_sec):
	assert(typeof(total_sec) == TYPE_INT)
	var total_min = total_sec / 60
	var hour = total_min / 60
	var minute = total_min % 60
	var second = total_sec % 60
	if hour < 1:
		return "%02dm %02ds" % [minute, second]
	else:
		return "%02dh %02dm" % [hour, minute]

static func FormatStepToSecond(steps):
	var in_secs = float(steps) / data.StepPerSec
	return "%.*fs" % [1 if decimals(in_secs) > 0 else 0, in_secs]

static func FormatPixelToTile(pixels):
	var in_tiles = float(pixels) / data.TileSizeInPixel
	return "%.*f" % [ 1 if decimals(in_tiles) > 0 else 0, in_tiles]

static func FormatSpeed(speed):
	if speed > 150:
		return "ID_VERYFAST"
	if speed > 100:
		return "ID_FAST"
	if speed > 75:
		return "ID_MEDIUM"
	if speed > 0:
		return "ID_SLOW"
	return null

static func FormatAttackType(target_types, attack_type, damage_type):
	var types = PoolStringArray()
	var VISIBLE_DAMAGE_TYPES = {
		"ID_SIEGE": data.Siege,
		"ID_ABATTACK": data.AntiShield,
		"ID_BOMBING": data.Death,
	}
	for k in VISIBLE_DAMAGE_TYPES:
		if data.DamageTypeIs(damage_type, VISIBLE_DAMAGE_TYPES[k]):
			types.append(k)
		if len(types) >= 2:
			break
	if len(types) == 0:
		return null
	return types.join(" & ")