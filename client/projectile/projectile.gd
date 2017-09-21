extends KinematicBody2D

var target
var hitafter

var queue_freed

onready var elapsed = 0

func _ready():
	pass

func _process(delta):
	elapsed += delta
	var remain = hitafter - elapsed
	if target.is_dead() or remain <= 0:
		queue_free()
		return
	var pos = get_pos()
	var target_pos = target.get_pos()
	set_rot(target_pos.angle_to_point(pos))
	var speed = pos.distance_to(target_pos) / remain * delta
	set_pos(pos + (target_pos - pos).normalized() * speed)

func initialize(_pos, _target, _hitafter):
	set_pos(_pos)
	target = _target
	hitafter = float(_hitafter) / 10
	set_process(true)