extends Object

var url
var body

signal Completed(success, body)

func _init(url, body):
	self.url = url
	self.body = body

func requestCompleted(result, response_code, headers, body):
	var dict
	if result != HTTPRequest.RESULT_SUCCESS:
		dict = {"ErrMessage": "request failed"}
	elif response_code != HTTPClient.RESPONSE_OK:
		dict = {"ErrMessage": "response code not ok"}
	else:
		dict = static_func.cast_float_to_int(parse_json(body.get_string_from_utf8()))
	emit_signal("Completed", [dict.ErrMessage == "", dict])
	call_deferred("free")