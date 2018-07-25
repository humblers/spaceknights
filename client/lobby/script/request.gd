extends Reference

var method
var path
var body
var use_cookie

signal response(success, body)

func _init(method, path, body, use_cookie):
	self.method = method
	self.path = path
	self.body = body
	self.use_cookie = use_cookie

func response(code, dict):
	var success = true
	if code != HTTPClient.RESPONSE_OK:
		success = false
	if dict.ErrMessage != "":
		success = false
	emit_signal("response", success, dict)