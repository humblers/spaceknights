extends Button

const LAST_ANIM_NAME = "step_11"

var next_scene = "res://tutorial/tutorial.tscn"

func _ready():
	event.emit_signal("LoadSceneCompleted")
	connect("button_up", self, "skipToNextAnimation")
	$Skip.connect("button_up", self, "skipToNextScene")
	$AnimationPlayer.connect("animation_finished", self, "animationFinished")
	var idx = 1
	while true:
		$AnimationPlayer.set_blend_time("step_%d" % [idx], "fade_out", 2)
		$AnimationPlayer.queue("step_%d" % [idx])
		idx += 1
		if $AnimationPlayer.has_animation("step_%d" % [idx]):
			$AnimationPlayer.queue("fade_out")
			continue
		break

func skipToNextAnimation():
	var cur_anim = $AnimationPlayer.current_animation
	if cur_anim == "fade_out":
		return
	var anim_len = $AnimationPlayer.get_animation(cur_anim).length
	$AnimationPlayer.advance(anim_len)

func animationFinished(anim_name):
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
		assert(err in [ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN])
	config.set_value("gameflag", "intro_skip", true)
	config.save(user.CONFIG_FILE_NAME)
	if config.has_section_key("gameflag", "agreement_skip")\
			and config.get_value("gameflag", "agreement_skip"):
		loading_screen.GoToScene(next_scene)
		return
	add_child(load("res://agreement/agreement.tscn").instance())

func skipToNextScene():
	$Skip.visible = false
	self.disconnect("button_up", self, "skipToNextAnimation")
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("fade_out")
	$AnimationPlayer.queue(LAST_ANIM_NAME)