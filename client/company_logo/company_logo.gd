extends Control

func _ready():
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")

	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
	user.locale = config.get_value("locale", "language")
	if user.locale == null:
		user.locale = OS.get_locale().split("_")[0]
		if err in [OK, ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN]:
			config.set_value("locale", "language", user.locale)
			config.save(user.CONFIG_FILE_NAME)
	TranslationServer.set_locale(user.locale)

	# determine next scene
	if not config.get_value("gameflag", "intro_skip"):
		loading_screen.goto_scene("res://intro/intro.tscn")
		return
	loading_screen.goto_scene("res://lobby/lobby.tscn")