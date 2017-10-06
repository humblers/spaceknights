extends Sprite

var target_radius
var target_position
var lifetime
var elapsed = 0

func _ready():
	set_fixed_process(true)

func initialize(target, lifetime):
	self.lifetime = lifetime
	target_position = target.get_pos()
	target_radius = global.UNITS[target.name].radius
	target.connect("position_changed", self, "update_target_position")

func update_target_position(position):
	target_position = position

func _fixed_process(delta):
	elapsed += delta
	var remaining = lifetime - elapsed
	if remaining <= 0:
		queue_free()
		return

	var position = get_pos()
	var direction = (target_position - position).normalized()
	var speed = (position.distance_to(target_position) - target_radius) / remaining
	set_pos(position + direction * speed * delta)
	set_rot(direction.angle())