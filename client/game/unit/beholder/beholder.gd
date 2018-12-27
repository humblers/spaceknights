extends "res://game/script/unit.gd"

var Decayable = preload("res://game/script/decayable.gd")

var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	New(id, "beholder", player.Team(), level, posX, posY, game)
	Decayable = Decayable.new()
	Decayable.Init(self)

func _ready():
	$Float/FloatAni.play("activate")

func TakeDamage(amount, damageType, attacker):
	if damageType in [data.Skill, data.Death]:
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	.TakeDamage(amount, damageType, attacker)

func Update():
	Decayable.TakeDecayDamage()
	if freeze > 0:
		attack = 0
		targetId = 0
		freeze -= 1
		return
	if target() == null:
		setTarget(findTarget())
		attack = 0
	var t = target()
	if t != null:
		if withinRange(t):
			if attack % attackInterval() == 0:
				t.TakeDamage(attackDamage(), damageType(), self)
			attack += 1
		else:
			attack = 0
			$Sound/Attack.stop()
	else:
		attack = 0
		$Sound/Attack.stop()
		
	# client only
	if targetId == 0:
		$AnimationPlayer.play("idle")
	show_laser(attack > 0)

func show_laser(enable):
	var n = get_node("Chassis/Tower/ShotPoint")
	n.visible = enable
	if enable:
		var from = n.global_position
		var to = (from - target().global_position).normalized()
		to = to * game.World().ToPixel(target().Radius())
		to = target().global_position + to
		n.get_node("HitPoint").global_position = to
		var beam = n.get_node("LaserBeam")
		beam.global_scale.y = (to - from).length() / beam.texture.get_height()
		beam.global_rotation = (to - from).angle() + PI/2
		if $Sound/Attack.playing == false:
			$Sound/Attack.play()
				
func Destroy():
	.Destroy()
	.Release()
	$AnimationPlayer.play("destroy")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func target():
	return game.FindUnit(targetId)

func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()
