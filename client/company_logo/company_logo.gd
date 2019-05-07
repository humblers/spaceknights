extends Control

func _ready():
	event.emit_signal("LoadSceneCompleted")
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
		loading_screen.GoToScene("res://intro/intro.tscn")
		return
	if not config.get_value("gameflag", "tutorial_skip"):
		loading_screen.GoToScene("res://tutorial/tutorial.tscn")
		return
	loading_screen.GoToScene("res://lobby/lobby.tscn")