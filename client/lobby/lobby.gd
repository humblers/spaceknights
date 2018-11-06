extends Control

func _ready():
	http.modal_dialog = $Headup/Modal
	var err = http.connect_to_host(config.LOBBY_HOST, config.LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		http.handle_error("Connect to lobby fail!!")
		return
	$Headup.lobby = self
	$Headup.scroll = $Scroll
	$Headup.page_select($Headup.page_btns[1], 1)
	$Pages/Card.lobby = self
	$Pages/Battle.lobby = self
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
	invalidate()

func invalidate():
	$Pages/Battle.invalidate()
	$Pages/Card.invalidate()

# temporary? avoid godot's button group foolish behavior(pressed button hover)
static func button_group_behavior(buttons, selected_idx):
	for i in len(buttons):
		var btn = buttons[i]
		var tex = btn.texture_pressed if i == selected_idx else btn.texture_disabled
		btn.texture_normal = tex