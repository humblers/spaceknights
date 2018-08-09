extends Node2D

var targetId = 0
var lifetime = 0
var damage = 0
var game

# client only
onready var anim = $AnimationPlayer.get_animation("attack")

func Init(targetId, lifetime, damage, game):
	self.targetId = targetId
	self.lifetime = lifetime
	self.damage = damage
	self.game = game

func Update(game):
	if lifetime <= 0:
		var target = game.FindUnit(targetId)
		if target != null:
			target.TakeDamage(damage)
	lifetime -= 1

func IsExpired():
	return lifetime < 0

func Destroy():
	queue_free()

func _ready():
	set_process(true)

func _process(delta):
	var target = game.FindUnit(targetId)
	if target == null:
		return
	update_hit_position(target.global_position)
	rotation = PI/2 + (target.position - position).angle()

func update_hit_position(gpos):
	$HitPosition.global_position = gpos
	for side in ["L", "R"]:
		for i in range(3):
			var path = "Missile%s%s:position" % [side, (i + 1)]
			var track_idx = anim.find_track(path)
			var key_idx = anim.track_get_key_count(track_idx) - 1
			anim.track_set_key_value(track_idx, key_idx, $HitPosition.position)
