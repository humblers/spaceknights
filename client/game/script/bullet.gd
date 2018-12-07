extends "res://game/script/bullet_base.gd"

func Destroy():
	queue_free()

func _process(delta):
	if lifetime > 0:
		var target = game.FindUnit(targetId)
		if target != null:
			var lifetimesec = float(lifetime)/game.STEP_PER_SEC
			var remain = target.position - position
			position += remain * (delta/lifetimesec)
			rotation = PI/2 + remain.angle()
			return
	hide()
