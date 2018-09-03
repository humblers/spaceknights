extends Node2D

var targetId = 0
var lifetime = 0
var damage = 0
var game
var anim

func Init(targetId, lifetime, damage, game):
	self.targetId = targetId
	self.lifetime = lifetime
	self.damage = damage
	self.game = game

func Update(game):
	if lifetime <= 0:
		var target = game.FindUnit(targetId)
		if target != null:
			target.TakeDamage(damage, "Range")
	lifetime -= 1

func IsExpired():
	return lifetime < 0

func Destroy():
	queue_free()

func _ready():
	set_process(true)
	var dup = $AnimationPlayer.get_animation("attack").duplicate()
	$AnimationPlayer.rename_animation("attack", "attack-ref")
	$AnimationPlayer.add_animation("attack", dup)
	$AnimationPlayer.play("attack")
	anim = dup
	update_trajectory(game.FindUnit(targetId).global_position)

func _process(delta):
	var target = game.FindUnit(targetId)
	if target == null:
		return
	update_hit_position(target.global_position)
	rotation = PI/2 + (target.position - position).angle()

func update_trajectory(hit_pos):
	$HitPosition.global_position = hit_pos
	for side in ["L", "R"]:
		for i in range(3):
			var path = "Missile%s%s:position" % [side, (i + 1)]
			var degree_path = "Missile%s%s:rotation_degrees" % [side, (i + 1)]
			var track_idx = anim.find_track(path)
			var degree_track_idx = anim.find_track(degree_path)
			var key_num = anim.track_get_key_count(track_idx)
			var degree_key_num = anim.track_get_key_count(degree_track_idx)
			
			for j in key_num-4:
				var r = (randi()%20+5)
				var offset = randi()%3-1
				var pos = $HitPosition.position * (j+1)/4
				r = r*offset
				var newpos = Vector2(anim.track_get_key_value(track_idx, j+4).x + r, pos.length()*-1)
				anim.track_set_key_value(track_idx, j+4, newpos)
				
			for j in degree_key_num-3:
				var ref_vec = Vector2(0, -1)
				var degree = rad2deg(ref_vec.angle_to(anim.track_get_key_value(track_idx, j+4)- anim.track_get_key_value(track_idx, j+3)))
				anim.track_set_key_value(degree_track_idx, j+3, degree)


func update_hit_position(gpos):
	$HitPosition.global_position = gpos
	for side in ["L", "R"]:
		for i in range(3):
			var path = "Missile%s%s:position" % [side, (i + 1)]
			var track_idx = anim.find_track(path)
			var key_idx = anim.track_get_key_count(track_idx) - 1
			anim.track_set_key_value(track_idx, key_idx, $HitPosition.position)

		
