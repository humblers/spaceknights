extends AnimatedSprite

func _ready():
	play("prepare")
	yield(self, "finished")
	play("active")

func initialize(spell):
	if global.team == spell.Team:
		set_rot(PI)
	set_z(global.LAYERS.GroundUnder)
	var pos = Vector2(spell.Knight.Position.X, 0)
	if global.team == "Visitor":
		pos.x = global.MAP.width - pos.x
	update_position(pos)

func update_position(position):
	set_pos(Vector2(position.x, global.MAP.height / 2))