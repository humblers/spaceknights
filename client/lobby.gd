extends Node

onready var id_holder = get_node("Auth/IDPlaceholder")
onready var login = get_node("Auth/Login")
onready var logout = get_node("Auth/Logout")
onready var match = get_node("Match")
onready var find_match = get_node("Match/Find")
onready var continue_match = get_node("Match/Continue")
onready var cancel_match = get_node("Match/Cancel")

func _ready():
	if kcp.is_connected():
		kcp.disconnect_server()
	http_lobby.connect("login_response", self, "_login_response")
	http_lobby.connect("match_response", self, "_match_response")
	http_lobby.connect("logout_response", self, "_logout_response")
	login.connect("pressed", self, "login_manually")
	logout.connect("pressed", self, "logout")
	find_match.connect("pressed", self, "find_match")
	continue_match.connect("pressed", self, "continue_match")
	cancel_match.connect("pressed", self, "cancel_match")
	try_auto_login()

func try_auto_login():
	if not global.config.has_section("login"):
		return
	for id in global.config.get_section_keys("login"):
		var token = global.config.get_value("login", id)
		global.config.set_value("login", id, null)
		global.save_config()
		http_lobby.request(HTTPClient.METHOD_POST,
				"/login/dev",
				{"id":id, "token":token},
				"login_response")
		return

func login_manually():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/login/dev",
			{"id":id_holder.get_text()},
			"login_response")

func logout():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/logout",
			{},
			"logout_response")

func activate_match_buttons():
	match.show()
	if global.config.has_section_key("match", global.id):
		find_match.hide()
		continue_match.show()
		cancel_match.show()
		return
	find_match.show()
	continue_match.hide()
	cancel_match.hide()

func find_match():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/match/find",
			{},
			"match_response")
	find_match.set_text("WAITING...")

func continue_match():
	_match_response(true, global.config.get_value("match", global.id))

func cancel_match():
	global.config.set_value("match", global.id, null)
	global.save_config()
	activate_match_buttons()

func _login_response(success, dict):
	if not success:
		print("login failed : ", dict)
		return
	global.id = dict.id
	global.config.set_value("login", global.id, dict.token)
	global.save_config()
	id_holder.set_text(global.id)
	id_holder.set_editable(false)
	id_holder.set_focus_mode(Control.FOCUS_NONE)
	login.hide()
	logout.show()
	activate_match_buttons()

func _logout_response(success, dict):
	match.hide()
	logout.hide()
	login.show()
	id_holder.set_focus_mode(Control.FOCUS_ALL)
	id_holder.set_editable(true)
	id_holder.set_text("")
	global.config.set_value("login", global.id, null)
	global.save_config()
	global.id = null

func _match_response(success, dict):
	find_match.set_text("FIND")
	if not success:
		print("match failed : ", dict)
		return
	
	global.config.set_value("match", global.id, dict)
	global.save_config()

	# kcp connect before scene loading
	kcp.connect_server(dict.host, 9999)
	kcp.send({"Id": global.id, "Token": global.id})
	kcp.send({"SessionId": dict.sid})
	get_tree().change_scene("res://game.tscn")