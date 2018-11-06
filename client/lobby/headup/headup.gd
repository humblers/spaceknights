extends CanvasLayer

var lobby
var scroll

onready var page_btns = [
	$Bot/Card,
	$Bot/Battle,
	$Bot/Explore,
]

func _ready():
	for i in len(page_btns):
		var btn = page_btns[i]
		btn.connect("button_up", self, "page_select", [btn, i])
	$Top/Config.connect("button_up", self, "show_config")
	$Config/MarginContainer/Close.connect("button_up", self, "hide_config")
	$Config/MarginContainer/Account/Change.connect("button_up", self, "change_uid")
	$Config/MarginContainer/Replay/Play.connect("button_up", self, "play_replay")

func invalidate():
	$Top/Level.text = "%d" % (user.Level + 1)
	$Top/Level/Exp.text = "%d/xxx" % user.Exp
	$Top/Galacticoin.text = "%d" % user.Galacticoin
	$Top/Dimensium.text = "%d" % user.Dimensium
	$Config/MarginContainer/Account/PID.text = user.PlatformId

func show_config():
	$Config.popup()

func hide_config():
	$Config.visible = false

func change_uid():
	var to = $Config/MarginContainer/Account/PIDEdit.text
	if to == "":
		return
	var config = ConfigFile.new()
	config.set_value("auth", "uid", to)
	config.save(user.CONFIG_FILE)
	http.cookie_str = ""
	loading_screen.goto_scene("res://lobby/lobby.tscn")

func page_select(btn, i):
	lobby.button_group_behavior(page_btns, i)
	scroll.move_to_page(btn)

func play_replay():
	#TODO : implement replay
	pass