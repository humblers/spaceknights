extends KinematicBody2D

var target_pos
var hitafter

onready var elapsed = 0

func _ready():
	pass

func _process(delta):
	elapsed += delta
	var remain = hitafter - elapsed
	if remain <= 0:
		queue_free()
		return
	var pos = get_pos()
	set_rot(target_pos.angle_to_point(pos))
	var speed = pos.distance_to(target_pos) / remain * delta
	set_pos(pos + (target_pos - pos).normalized() * speed)

func initialize(_pos, _target, _hitafter):
	set_pos(_pos)
	target_pos = _target.get_pos()
	_target.connect("to_projectile", self, "update_target")
	hitafter = float(_hitafter) / 10
	set_process(true)

func update_target(is_dead, pos):
	if is_dead:
		queue_free()
		return
	target_pos = pos