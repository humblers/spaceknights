extends "res://game/script/bullet_base.gd"

var anim
var trajectory_initialized = false

func Destroy():
	queue_free()

func _ready():
	var dup = $AnimationPlayer.get_animation("attack").duplicate()
	$AnimationPlayer.rename_animation("attack", "attack-ref")
	$AnimationPlayer.add_animation("attack", dup)
	$AnimationPlayer.play("attack")
	anim = dup

func _process(delta):
	var target = game.FindUnit(targetId)
	if target == null:
		return
	if not trajectory_initialized:
		init_trajectory(target.global_position)
		trajectory_initialized = true
	update_hit_position(target.global_position)
	rotation = PI/2 + (target.position - position).angle()

func init_trajectory(hit_pos):
	$HitPosition.global_position = hit_pos
	for side in ["L", "R"]:
		for i in range(4):
			var path = "Missile%s%s:position" % [side, (i + 1)]
			var degree_path = "Missile%s%s:rotation_degrees" % [side, (i + 1)]
			var track_idx = anim.find_track(path)
			var degree_track_idx = anim.find_track(degree_path)
			var key_num = anim.track_get_key_count(track_idx)
			var degree_key_num = anim.track_get_key_count(degree_track_idx)
			
			for j in key_num-4:
				var r = (randi()%20+20)
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

		
