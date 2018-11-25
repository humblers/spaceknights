extends CanvasLayer

const PAGES = ["Card", "Battle", "Explore", "Shop"]

var lobby
var scroll

export(NodePath) onready var bot = get_node(bot)

export(NodePath) onready var card_page_btn = get_node(card_page_btn)
export(NodePath) onready var battle_page_btn = get_node(battle_page_btn)
export(NodePath) onready var explore_page_btn = get_node(explore_page_btn)
export(NodePath) onready var shop_page_btn = get_node(shop_page_btn)

export(NodePath) onready var config = get_node(config)
export(NodePath) onready var config_btn = get_node(config_btn)
export(NodePath) onready var config_close_btn = get_node(config_close_btn)
export(NodePath) onready var config_auth_btn = get_node(config_auth_btn)
export(NodePath) onready var config_auth_label = get_node(config_auth_label)
export(NodePath) onready var config_auth_lineedit = get_node(config_auth_lineedit)

export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var exp_label = get_node(exp_label)
export(NodePath) onready var galacticoin_label = get_node(galacticoin_label)
export(NodePath) onready var dimensium_label = get_node(dimensium_label)

export(NodePath) onready var requesting_dialog = get_node(requesting_dialog)

func _ready():
	for page in PAGES:
		var btn = get("%s_page_btn" % page.to_lower())
		btn.connect("button_up", self, "page_select", [page])
	config_btn.connect("button_up", self, "show_config")
	config_close_btn.connect("button_up", self, "hide_config")
	config_auth_btn.connect("button_up", self, "modify_auth")

func invalidate():
	level_label.text = "%d" % (user.Level + 1)
	exp_label.text = "%d/xxx" % user.Exp
	galacticoin_label.text = "%d" % user.Galacticoin
	dimensium_label.text = "%d" % user.Dimensium
	config_auth_label.text = user.PlatformId

func show_config():
	config.popup()

func hide_config():
	config.visible = false

func modify_auth():
	var to = config_auth_lineedit.text
	if to == "":
		return
	var config = ConfigFile.new()
	config.set_value("auth", "pid", to)
	config.save(user.CONFIG_FILE)
	http.cookie_str = ""
	loading_screen.goto_scene("res://lobby/lobby.tscn")

func page_select(page):
	scroll.move_to_page(page)