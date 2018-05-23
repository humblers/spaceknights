extends AnimatedSprite

var s_name

func _ready():
	play("prepare")

func initialize(spell):
	s_name = spell.Name
	if global.team == spell.Team:
		self.rotation = PI
	self.z_index = global.LAYERS.GroundUnder
	var size = get_sprite_frames().get_frame(get_animation(), 0).get_size()
	self.scale = global.get_scale(spell.Name, size)
	self.position = get_position(spell)

func release():
	if s_name == "freeze":
		queue_free()
		return
	if get_sprite_frames().get_animation_loop(get_animation()):
		queue_free()
		return
	yield(self, "animation_finished")
	queue_free()

func get_position(spell):
	var x = spell.Position.X
	var y = spell.Position.Y
	if global.team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(global.MAP.width - x, global.MAP.height - y)

func update_position(id, position):
	self.position = Vector2(position.x, global.MAP.height / 2)