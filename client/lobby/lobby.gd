extends Control

const LOBBY_HOST = "127.0.0.1"
const LOBBY_PORT = 8080

func _ready():
	for page in ["Battle", "Card"]:
		var btn = $Headup/Bot.get_node(page)
		btn.connect("button_up", $Scroll, "move_to_page", [btn])

	var err = http.connect_to_host(LOBBY_HOST, LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		http.handle_error("Connect to lobby fail!!")
		return
	http.modal_dialog = $Headup/Modal
	load_data()

func load_data():
	var response = yield(http.new_request(HTTPClient.METHOD_POST, "/data/cards"), "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	stat.cards = converter.cast_float_to_int(parse_json(response[1]["Data"]))
	response = yield(http.new_request(HTTPClient.METHOD_POST, "/data/units"), "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	stat.units = converter.cast_float_to_int(parse_json(response[1]["Data"]))
	login()

func login():
	var params = { "ptype": "dev" }
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE)
	if err == OK:
		if config.has_section_key("auth", "uid"):
			params["pid"] = config.get_value("auth", "uid")
	var req = http.new_request(HTTPClient.METHOD_POST, "/auth/login",
			params)
	var response = yield(req, "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	user.Id = response[1].UID
	user.PlatformId = response[1].PID
	config.set_value("auth", "uid", user.PlatformId)
	config.save(user.CONFIG_FILE)
	for k in response[1].User.keys():
		user.set(k, response[1].User[k])
	$Headup.invalidate()
	$Pages/Card.invalidate()
	$Pages/Battle/Mid/Match.connect("pressed", self, "match_request")

func match_request():
	var req = http.new_request(HTTPClient.METHOD_POST, "/match/request")
	$Pages/Battle/Requesting.pop(req)
	var resp = yield(req, "response")
	var cfg = resp[1].Config
	tcp.Connect(resp[1].Address, 9999)
	yield(tcp, "connected")
	tcp.Send({"Id": user.Id, "Token": user.Id})
	tcp.Send({"GameId": cfg.Id})
	var param = {"connected": true, "cfg": cfg}
	loading_screen.goto_scene("res://game/game.tscn", param)