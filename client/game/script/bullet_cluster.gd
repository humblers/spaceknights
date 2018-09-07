extends Node2D

const BULLET_COUNT = 6
const SHOT_INTERVAL = 0.05

var targetId = 0
var lifetime = 0
var damage = 0
var slowDuration = 0
var game

var spawnerId
var shotpoints = {"Left": "", "Right": ""}
var bullet_count = 0
var target_pos
var lifetimesec

func Init(targetId, lifetime, damage, game):
	self.targetId = targetId
	self.lifetime = lifetime
	self.damage = damage
	self.game = game
	lifetimesec = float(lifetime)/game.STEP_PER_SEC + BULLET_COUNT * SHOT_INTERVAL

func Update():
	if lifetime <= 0:
		var target = game.FindUnit(targetId)
		if target != null:
			target.TakeDamage(damage, "Range")
			target.MakeSlow(slowDuration)
	lifetime -= 1

func IsExpired():
	return lifetime < 0

func Destroy():
	while lifetimesec > 0:
		yield(get_tree(), "idle_frame")
	queue_free()
	
func MakeFrozen(slowDuration):
	self.slowDuration = slowDuration

func _ready():
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
