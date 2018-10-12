extends Node

const REQUEST = preload("res://lobby/script/request.gd")
const CONNECTION_TIMEOUT = 5000
const CONNECTION_POLLING_DELAY = 500

# HTTPClient
# http://docs.godotengine.org/en/3.0/tutorials/networking/http_client_class.html
var client = HTTPClient.new()

var cookie_str # storing cookie in memory(temporary)
var response_body = PoolByteArray()
var req_queue = []

func _process(delta):
	# Keep polling until the request is going on
	if client.get_status() == HTTPClient.STATUS_REQUESTING:
		client.poll()
		return
	handle_response()
	handle_request()

func handle_response():
	if not client.has_response():
		return

	#print("Response is Chunked? ", client.is_response_chunked())
	# works for both(chunk, plain) anyway. 
	if client.get_status() == HTTPClient.STATUS_BODY:
		client.poll()
		var chunk = client.read_response_body_chunk()
		if chunk.size() != 0:
			response_body += chunk

	# there is no body left to be read
	if client.get_status() == HTTPClient.STATUS_CONNECTED:
		var code = client.get_response_code() # response code
		var headers = client.get_response_headers_as_dictionary() # Get response headers
		if headers.has("Set-Cookie"):
			cookie_str = headers["Set-Cookie"]
		#print("code: ", code)
		#print("headers: ", headers)
		var text = response_body.get_string_from_utf8()
		#text = text.to_lower()
		var request = req_queue.pop_front()
		request.response(code, parse_json(text))
		response_body = PoolByteArray()

func handle_request():
	if req_queue.size() <= 0:
		return
	# client not ready for next request
	if client.get_status() != HTTPClient.STATUS_CONNECTED:
		return
	var headers = [] # no need to add Content-Length, User-Agent, Accept
	var next = req_queue.front()
	if next.method == HTTPClient.METHOD_POST:
		headers.append("Content-Type: application/json")
	if next.use_cookie:
		headers.append("Cookie: %s" % cookie_str)
	var err = client.request(next.method, next.path, headers, next.body)
	if err != OK:
		var request = req_queue.pop_front()
		request.response(-999, {"errmessage": "unexpected client error"})

func connect_to_host(host, port):
	var err = client.connect_to_host(host, port)
	if err != OK:
		return err
	var conn_elapsed = 0
	while (client.get_status() == HTTPClient.STATUS_CONNECTING or\
			client.get_status() == HTTPClient.STATUS_RESOLVING):
		client.poll()
		OS.delay_msec(CONNECTION_POLLING_DELAY)
		conn_elapsed += CONNECTION_POLLING_DELAY
		if conn_elapsed >= CONNECTION_TIMEOUT:
			return ERR_TIMEOUT
	if client.get_status() != HTTPClient.STATUS_CONNECTED:
		return ERR_UNAVAILABLE
	return OK

func new_request(method, path, params={}, use_cookie=true):
	var req = REQUEST.new(method, path, to_json(params), use_cookie)
	req_queue.push_back(req)
	return req