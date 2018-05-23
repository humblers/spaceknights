extends Control

signal auth_updated

func _ready():
	http_lobby.connect("login_response", self, "login_response")
	http_lobby.connect("logout_response", self, "logout_response")
	$Login.connect("pressed", self, "login_manually")
	$Logout.connect("pressed", self, "logout")

func try_auto_login():
	if not global.config.has_section("login"):
		emit_signal("auth_updated")
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
	emit_signal("auth_updated")

func login_manually():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/login/dev",
			{"id":$IDPlaceholder.get_text()},
			"login_response")

func logout():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/logout",
			{},
			"logout_response")

func login_response(success, dict):
	if not success:
		print("login failed : ", dict)
		return
	global.id = dict.id
	global.config.set_value("login", global.id, dict.token)
	global.save_config()
	$IDPlaceholder.set_text(global.id)
	$IDPlaceholder.set_editable(false)
	$IDPlaceholder.set_focus_mode(Control.FOCUS_NONE)
	$Login.hide()
	$Logout.show()
	emit_signal("auth_updated")

func logout_response(success, dict):
	$Logout.hide()
	$Login.show()
	$IDPlaceholder.set_focus_mode(Control.FOCUS_ALL)
	$IDPlaceholder.set_editable(true)
	$IDPlaceholder.set_text("")
	global.config.set_value("login", global.id, null)
	global.save_config()
	global.id = null
	emit_signal("auth_updated")