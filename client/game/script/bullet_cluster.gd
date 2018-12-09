extends "bullet_base.gd"

const SHOT_INTERVAL = 0.05

var BULLET_COUNT
var spawnerId
var shotpoints = {"Left": "", "Right": ""}
var bullet_count = 0
var target_pos
var lifetimesec

func Init(targetId, lifetime, damage, damageType, game):
	.Init(targetId, lifetime, damage, damageType, game)
	lifetimesec = float(lifetime)/data.StepPerSec + BULLET_COUNT * SHOT_INTERVAL

func Destroy():
	while lifetimesec > 0:
		yield(get_tree(), "idle_frame")
	queue_free()

func _ready():
	var target = game.FindUnit(targetId)
	if target != null:
		target_pos = target.global_position
	add_bullet()
	$Timer.wait_time = SHOT_INTERVAL
	$Timer.start()
	$Timer.connect("timeout", self, "add_bullet")

func add_bullet():
	if bullet_count < BULLET_COUNT:
		var spawner = game.FindUnit(spawnerId)
		if spawner == null:
			return
		for side in ["Left", "Right"]:
			var n = get_node("%s%s" % [side, bullet_count + 1])
			n.visible = true
			n.global_position = spawner.get_node(shotpoints[side]).global_position
		bullet_count += 1
	else:
		$Timer.stop()

func _process(delta):
	var target = game.FindUnit(targetId)
	if target != null:
		target_pos = target.global_position
	for side in ["Left", "Right"]:
		for i in bullet_count:
			var n = get_node("%s%s" % [side, i + 1])
			var remain = target_pos - n.global_position
			var t = lifetimesec - (BULLET_COUNT - (i+1)) * SHOT_INTERVAL
			if t <= 0:
				n.visible = false
				continue
			else:
				t = min(delta/t, 1)
			n.global_position += remain * t
			n.global_rotation = PI/2 + remain.angle()
	lifetimesec -= delta
