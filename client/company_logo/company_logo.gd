extends Control

func _ready():
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")
	loading_screen.goto_scene("res://lobby/lobby.tscn")

	user.locale = OS.get_locale().split("_")[0]
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err == OK:
		if config.has_section_key("locale", "language"):
			user.locale = config.get_value("locale", "language")
	TranslationServer.set_locale(user.locale)
