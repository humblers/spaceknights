extends PopupPanel

export(NodePath) onready var hud = get_node(hud)

export(NodePath) onready var close_btn = get_node(close_btn)
export(NodePath) onready var auth_btn = get_node(auth_btn)
export(NodePath) onready var locale_btn = get_node(locale_btn)
export(NodePath) onready var auth_label = get_node(auth_label)
export(NodePath) onready var auth_line_edit = get_node(auth_line_edit)

func _ready():
	close_btn.connect("button_up", self, "hide_config")
	auth_btn.connect("button_up", self, "modify_auth")
	locale_btn.connect("button_up", self, "toggle_locale")

func PopUp():
	auth_label.text = user.PlatformId
	self.popup()

func hide_config():
	self.visible = false

func modify_auth():
	var to = auth_line_edit.text
	if to == "":
		return
	var config = ConfigFile.new()
	config.set_value("auth", "pid", to)
	config.save(user.CONFIG_FILE_NAME)
	user.http_cookie_str = ""
	loading_screen.goto_scene("res://company_logo/company_logo.tscn")

func toggle_locale():
	user.locale = "en" if user.locale != "en" else "ko"
	var config = ConfigFile.new()
	config.set_value("locale", "language", user.locale)
	config.save(user.CONFIG_FILE_NAME)
	TranslationServer.set_locale(user.locale)