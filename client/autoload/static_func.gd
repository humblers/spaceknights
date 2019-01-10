extends Node
	
static func draw_circle_arc(cavas_item, center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	for index_point in range(nb_points):
		cavas_item.draw_line(points_arc[index_point], points_arc[index_point + 1], color)

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

static func set_text(label, text, autowrap = false, min_size = 28):
	if label.text == text:
		return
	var font = label.get_font("font")
	assert(font != null)
	while font.size > min_size:
		var size = font.get_string_size(text)
		if size.x <= label.rect_size.x and size.y <= label.rect_size.y:
			break
		font.size -= 1
	label.autowrap = autowrap
	label.text = text

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