extends Node2D

var child_idx = 0

signal projectile_created(type, target, lifetime, initial_position)

func projectile_create(unit_name, target):
	var data = global.UNITS[unit_name]
	if not data.has("projectile"):
		return

	match unit_name:
		"archer":
			child_idx += 1
			if child_idx >= self.get_child_count():
				child_idx = 0
			emit_signal("projectile_created",
					data.projectile,
					target,
					float(data.prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
					self.get_child(child_idx).global_position)
		_:
			emit_signal("projectile_created",
					data.projectile,
					target,
					float(data.prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
					self.global_position)