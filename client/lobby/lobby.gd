extends Control

func _ready():
	for page in ["Battle", "Card"]:
		var btn = $Headup/Bot.get_node(page)
		btn.connect("button_up", $Scroll, "move_to_page", [btn])
	http.modal_dialog = $Headup/Modal
	var err = http.connect_to_host(config.LOBBY_HOST, config.LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		http.handle_error("Connect to lobby fail!!")
		return
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
	$Pages/Battle.invalidate()
	$Pages/Card.invalidate()