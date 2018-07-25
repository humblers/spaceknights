extends Node

const LOBBY_HOST = "13.125.74.237"
const LOBBY_PORT = 8080

func _ready():
	var err = http.connect_to_host(LOBBY_HOST, LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		handle_error("Connect to lobby fail!!")
		return
	login()
	load_data()

# simply all error back to login process
func handle_error(message):
	$Modal.pop(message)
	yield($Modal, "popup_hide")
	return

func login():
	var req = http.new_request(HTTPClient.METHOD_POST, "/auth/login",
			{ "ptype": "dev", "pid": "", })
	var response = yield(req, "response")
	if not response[0]:
		handle_error(response[1].ErrMessage)
		return
	var user = response[1].User
	$Battle.id = response[1].UID
	$Battle.set_top_information(user.Level, user.Exp, user.Galacticoin, user.Dimensium)

func load_data():
	var overwrite = false # set true when production level
	for path in ["Cards", "Units"]:
		var response = yield(http.new_request(HTTPClient.METHOD_POST, "/data/%s" % path.to_lower()), "response")
		if not response[0]:
			handle_error(response[1].ErrMessage)
			return
		stat.set_data(path.to_lower(), response[1][path], overwrite)