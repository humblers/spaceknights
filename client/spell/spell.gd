extends AnimatedSprite

func _ready():
	play("prepare")

func initialize(spell):
	if global.team == spell.Team:
		set_rot(PI)
	set_z(global.LAYERS.GroundUnder)
	var size = get_sprite_frames().get_frame(get_animation(), 0).get_size()
	set_scale(global.get_scale(spell.Name, size))
	set_pos(get_position(spell))

func release():
	if get_sprite_frames().get_animation_loop(get_animation()):
		queue_free()
		return
	yield(self, "finished")
	queue_free()

func get_position(spell):
	var x = spell.Position.X
	var y = spell.Position.Y
	if global.team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(global.MAP.width - x, global.MAP.height - y)

func update_position(id, position):
	set_pos(Vector2(position.x, global.MAP.height / 2))