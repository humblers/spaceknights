extends Sprite

var target_radius
var target_position
var lifetime
var elapsed = 0

func _ready():
	set_physics_process(true)

func set_single_target(target, lifetime, position, parent):
	self.lifetime = lifetime
	self.position = position
	self.z_index = global.LAYERS.Projectile
	target_position = parent.to_local(target.global_position)
	target_radius = global.UNITS[target.u_name].radius
	target.connect("position_changed", self, "update_target_position")

func update_target_position(id, position):
	target_position = get_parent().to_local(position)

func _physics_process(delta):
	elapsed += delta
	var remaining = lifetime - elapsed
	if remaining <= 0:
		queue_free()
		return

	var position = self.position
	var direction = (target_position - position).normalized()
	var speed = (position.distance_to(target_position) - target_radius) / remaining
	self.position = position + direction * speed * delta
	self.rotation = direction.angle() - PI / 2