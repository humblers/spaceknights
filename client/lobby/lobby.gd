extends Node

const PAGES = ["Battle", "Card", "Explore", "Shop", "Social"]

export(NodePath) onready var hud = get_node(hud)
export(NodePath) onready var input_manager = get_node(input_manager)
export(NodePath) onready var http_manager = get_node(http_manager)
export(NodePath) onready var firebase_auth_manager = get_node(firebase_auth_manager)
export(NodePath) onready var resource_manager = get_node(resource_manager)
export(NodePath) onready var page_battle = get_node(page_battle)
export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var page_explore = get_node(page_explore)
export(NodePath) onready var page_shop = get_node(page_shop)
export(NodePath) onready var page_social = get_node(page_social)

func _ready():
	global_object.lobby = self
	input_manager.move_to_page(PAGES[0])
	http_manager.cookie_str = user.http_cookie_str
	http_manager.error_dialog = hud.error_dialog
	var err = http_manager.connect_to_host(config.LOBBY_HOST, config.LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		http_manager.handle_error("Connect to lobby fail!!")
		return
	requestNewChest()
	load_data()

func load_data():
	for path in ["cards", "units", "Chests", "ChestOrder"]:
		var response = yield(http_manager.new_request(HTTPClient.METHOD_POST, "/data/%s" % path.to_lower()), "response")
		if not response[0]:
			http_manager.handle_error(response[1].ErrMessage)
			return
		data.set(path, static_func.cast_float_to_int(parse_json(response[1]["Data"])))
	for path in ["upgrade"]:
		var response = yield(http_manager.new_request(HTTPClient.METHOD_POST, "/data/%s" % path), "response")
		if not response[0]:
			http_manager.handle_error(response[1].ErrMessage)
			return
		var d = static_func.cast_float_to_int(parse_json(response[1]["Data"]))
		data.set(path.capitalize(), resource_manager.scripts.get_resource(path).new(d))
	login()

func login():
	var params = {}
	if firebase_auth_manager.has_user():
		firebase_auth_manager.retrieve_token()
		var res = yield(firebase_auth_manager, "on_retrieve_token_complete")
		if res.auth_error != firebase_auth_manager.kAuthErrorNone:
			http_manager.handle_error(res.error_message)
			return
		params["firebasetoken"] = res.token
	var req = http_manager.new_request(HTTPClient.METHOD_POST, "/auth/login", params)
	var response = yield(req, "response")
	if not response[0]:
		http_manager.handle_error(response[1].ErrMessage)
		return
	if response[1].FirebaseToken != "":
		firebase_auth_manager.sign_in_with_custom_token(response[1].FirebaseToken)
		var res = yield(firebase_auth_manager, "on_sign_in_complete")
		if res.auth_error != firebase_auth_manager.kAuthErrorNone:
			http_manager.handle_error(res.error_message)
			return
	user.http_cookie_str = http_manager.cookie_str
	user.Id = response[1].UID
	for k in response[1].User.keys():
		user.set(k, response[1].User[k])
	Invalidate()

func Invalidate():
	hud.invalidate()
	page_battle.invalidate()
	page_card.Invalidate()

func requestNewChest():
	if not user.request_new_chest:
		return
	user.request_new_chest = false
	var req = http_manager.new_request(
			HTTPClient.METHOD_POST, 
			"/chest/new",
			{ "Name": "Battle", "Rank": user.Rank })
	var response = yield(req, "response")
	if not response[0]:
		http_manager.handle_error(response[1].ErrMessage)
		return