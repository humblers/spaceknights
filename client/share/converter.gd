extends Node

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
