extends Node

const LOBBY_HOST = "http://127.0.0.1"
const LOBBY_PORT = 3333

var http = HTTPClient.new()
var timer = Timer.new()
var req_queue = []
var response_body = RawArray()
var reserved_signal

signal login_success(ret)
#signal failure(err_code, err_msg)

func _ready():
	if not validate_conn() and not connect_to_lobby():
		print("connect fail. To Do - rollback to launch scene")
		return
	timer.set_wait_time(1.0/kcp.READ_RATE)
	timer.connect("timeout", self, "_poll")
	add_child(timer)
	timer.start()
	#request(HTTPClient.METHOD_POST, "/login/dev", {"id":"1", "token":"temp"}, "login_success")

func emit_reserved_signal(ret):
	print(ret)
	if reserved_signal != null:
		emit_signal(reserved_signal, ret)
		reserved_signal = null

func _poll():
	# ongoing request poll and return
	if http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		print("Requesting..")
		return

	# get response and return response by emit signal 
	if (http.has_response()):
		var headers = http.get_response_headers_as_dictionary()
		print("code: ",http.get_response_code())
		print("**headers:\\n",headers)

		if (http.is_response_chunked()):
			print("Response is Chunked!")
		else:
			var bl = http.get_response_body_length()
			print("Response Length: ",bl)

		if http.get_status()==HTTPClient.STATUS_BODY:
			http.poll()
		var chunk = http.read_response_body_chunk()
		if (chunk.size()==0):
			return

		response_body = response_body + chunk
		print("bytes got: ",response_body.size())
		var text = response_body.get_string_from_utf8()
		var ret = {}
		ret.parse_json(text)
		response_body = RawArray()
		emit_reserved_signal(ret)

	var next_request = req_queue.front()
	if next_request == null:
		return
	req_queue.pop_front()
	var headers=[
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*",
	]
	var method = next_request[0]
	var url = next_request[1]
	var body = ""
	if method == HTTPClient.METHOD_POST:
		body = next_request[2].to_json()
		headers = headers + [
			"Content-Type: application/json",
			"Content-Length: %d" % body.length(),
		]
	reserved_signal = next_request[3]
	var err = http.request(method, url, headers, body)
	if err != OK:
		emit_reserved_signal({"err_code":-999, "err_msg":"unknown"})

func connect_to_lobby():
	var err = http.connect(LOBBY_HOST, LOBBY_PORT)
	if err != OK:
		return false
	while( http.get_status()==HTTPClient.STATUS_CONNECTING or http.get_status()==HTTPClient.STATUS_RESOLVING):
		http.poll()
		print("Connecting..")
		OS.delay_msec(500)
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		return false
	return true

func validate_conn():
	var conn = http.get_connection()
	if conn == null or not conn.is_connected():
		return false
	return true

func request(method, path, params, signal_name):
	if not validate_conn():
		print("validating error!!")
		return "err"

	req_queue.push_back([method, path, params, signal_name])