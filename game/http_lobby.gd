extends Node

const LOBBY_HOST = "http://127.0.0.1"
const LOBBY_PORT = 3333

var http = HTTPClient.new()
var timer = Timer.new()
var req_queue = []
var cur_req_callback

signal login_success(ret)
signal failure(err_code, err_msg)

func _ready():
	if not validate_conn() and not connect_to_lobby():
		print("connect fail. To Do - rollback to launch scene")
		return
	#http.set_blocking_mode(true)
	#print("blocking enabled?", http.is_blocking_mode_enabled())
	timer.set_wait_time(1.0/kcp.READ_RATE)
	timer.connect("timeout", self, "_poll")
	add_child(timer)
	timer.start()
	#request(HTTPClient.METHOD_GET, "/ping", {}, funcref(self, "callback"))
	request(HTTPClient.METHOD_POST, "/login/dev", {"id":"1", "token":"temp"}, funcref(self, "callback"))

func callback(ret):
	print(ret)

func _poll():
	if http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		print("Requesting..")
		return
	if (http.has_response()):
		var headers = http.get_response_headers_as_dictionary() # Get response headers
		print("code: ",http.get_response_code()) # Show response code
		print("**headers:\\n",headers) # Show headers
		
		# Getting the HTTP Body
		
		if (http.is_response_chunked()):
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			print("Response Length: ",bl)
				
		# This method works for both anyway
		
		var rb = RawArray() # Array that will hold the data
		
		if http.get_status()==HTTPClient.STATUS_BODY:
			http.poll()

		var chunk = http.read_response_body_chunk() # Get a chunk
		if (chunk.size()==0):
			return
		rb = rb + chunk # Append to read buffer
		print("bytes got: ",rb.size())
		var text = rb.get_string_from_utf8()
		cur_req_callback.call_func(text)
		cur_req_callback = null
		return
	if req_queue.size() <= 0:
		return
	var request = req_queue[0]
	req_queue.pop_front()
	cur_req_callback = request[3]
	# Some headers
	var headers=[
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*",
	]
	var method = request[0]
	var body = ""
	if method == HTTPClient.METHOD_POST:
		body = request[2].to_json()
		headers.append("Content-Type: application/json")
		headers.append("Content-Length: %d" % body.length())
	var err = http.request(request[0], request[1], headers, body)
	if err != OK:
		cur_req_callback.call_func("err")
		cur_req_callback = null
		return

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

func request(method, path, params, callback_func):
	if not validate_conn():
		print("validating error!!")
		return "err"

	req_queue.push_back([method, path, params, callback_func])