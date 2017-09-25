extends AnimatedSprite

var animation
var frame

signal changed(animation, frame)

func _ready():
	animation = ""
	frame = -1
	set_process(true)

func _process(delta):
	var prev_anim = animation
	var prev_frame = frame
	animation = get_animation()
	frame = get_frame()
	if animation != prev_anim or frame != prev_frame:
		emit_signal("changed", animation, frame)