extends AnimatedSprite

func initialize(spell):
	if global.team == spell.Team:
		set_rot(PI)

func set_prepare_animation():
	play("prepare")

func update_changes(spell):
	play("active")
	set_pos(Vector2(spell.Position.X, spell.Position.Y))