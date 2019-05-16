extends TextureRect

var next_scene = "res://tutorial/tutorial.tscn"

onready var privacy_policy_label = $PanelContainer/VBoxContainer/PrivacyPolicy
onready var privacy_policy_agree = $PanelContainer/VBoxContainer/PrivacyAgreeContainer/PrivacyAgree
onready var tos_label = $PanelContainer/VBoxContainer/TOS
onready var tos_agree = $PanelContainer/VBoxContainer/TOSAgreeContainer/TOSAgree

func _ready():
	privacy_policy_label.text = tr(privacy_policy_label.text)
	tos_label.text = tr(tos_label.text)
	privacy_policy_agree.connect("toggled", self, "checkAgree")
	tos_agree.connect("toggled", self, "checkAgree")

func checkAgree(toggled):
	if not privacy_policy_agree.pressed:
		return
	if not tos_agree.pressed:
		return
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
		assert(err in [ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN])
	config.set_value("gameflag", "agreement_skip", true)
	config.save(user.CONFIG_FILE_NAME)
	loading_screen.GoToScene(next_scene)