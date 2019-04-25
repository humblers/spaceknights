extends Button

const LAST_ANIM_NAME = "step_11"

var next_scene = "res://lobby/lobby.tscn"

func _ready():
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
	goToNextScene()

func skipToNextScene():
	$Skip.visible = false
	self.disconnect("button_up", self, "skipToNextAnimation")
	$AnimationPlayer.play("fade_out")
	$AnimationPlayer.seek($AnimationPlayer.get_animation("fade_out").length, true)
	$AnimationPlayer.play(LAST_ANIM_NAME)

func goToNextScene():
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
		assert(err in [ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN])
	config.set_value("gameflag", "intro_skip", true)
	config.save(user.CONFIG_FILE_NAME)
	loading_screen.GoToScene(next_scene)