extends Control

func _ready():
	event.emit_signal("LoadSceneCompleted")
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")

	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)

	if not config.has_section_key("gameflag", "intro_skip")\
			or not config.get_value("gameflag", "intro_skip"):
		loading_screen.GoToScene("res://intro/intro.tscn")
		return
	if not config.has_section_key("gameflag", "agreement_skip")\
			or not config.get_value("gameflag", "agreement_skip"):
		add_child(load("res://agreement/agreement.tscn").instance())
		return
	if not config.has_section_key("gameflag", "tutorial_skip")\
			or not config.get_value("gameflag", "tutorial_skip"):
		loading_screen.GoToScene("res://tutorial/tutorial.tscn")
		return
	loading_screen.GoToScene("res://lobby/lobby.tscn")