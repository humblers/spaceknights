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
	var target = game.FindUnit(targetId)
	if target == null:
		return
	if target.team == "Blue":
		self.rotation = PI
		
func _process(delta):
	var target = game.FindUnit(targetId)
	if target == null:
		return
	if not trajectory_initialized:
		init_trajectory(target.global_position)
		trajectory_initialized = true
	update_hit_position(target.global_position)
	
func init_trajectory(hit_pos):
	$HitPosition.global_position = hit_pos
	for side in ["L", "R"]:
		for i in range(1):
			var path = "HeavyMissile%s%s:position" % [side, (i + 1)]
			var track_idx = anim.find_track(path)
			var key_idx = anim.track_get_key_count(track_idx) - 1
			anim.track_set_key_value(track_idx, key_idx, $HitPosition.position)
			var offset = anim.track_get_key_value(track_idx, key_idx -1)
			
			var off_vec = $HitPosition.position - offset
			
			var ref_vec = Vector2(0, -1)
			var degree_path = "HeavyMissile%s%s:rotation_degrees" % [side, (i + 1)]
			var degree_track_idx = anim.find_track(degree_path)
			var degree_key_idx = anim.track_get_key_count(degree_track_idx) -1
			var degree = rad2deg(ref_vec.angle_to(off_vec))
			anim.track_set_key_value(degree_track_idx, degree_key_idx, degree)
			
func update_hit_position(gpos):
	$HitPosition.global_position = gpos
	for side in ["L", "R"]:
		for i in range(1):
			var path = "HeavyMissile%s%s:position" % [side, (i + 1)]
			var track_idx = anim.find_track(path)
			var key_idx = anim.track_get_key_count(track_idx) - 1
			anim.track_set_key_value(track_idx, key_idx, $HitPosition.position)

		
