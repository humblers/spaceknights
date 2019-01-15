extends "res://game/script/unit.gd"

# invariants
export(Color) var beam_color_min = Color(0.63, 0.84, 1, 1)
export(Color) var beam_color_max = Color(0.63, 0.84, 1, 1)
export(float) var beam_width_min = 1.0
export(float) var beam_width_max = 4.0
var Decayable = preload("res://game/script/decayable.gd")
var damage_max

var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	New(id, "beholder", player.Team(), level, posX, posY, game)
	Decayable = Decayable.new()
	Decayable.Init(self)

func _ready():
	$Float/FloatAni.play("activate")
	damage_max = .attackDamage() * data.units[name_]["amplifycountlimit"]

func TakeDamage(amount, damageType, attacker):
	if data.DamageTypeIs(damageType, data.DecreaseOnKnight):
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	.TakeDamage(amount, damageType, attacker)

func Destroy():
	.Destroy()
	Release()
	$AnimationPlayer.play("destroy")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func attackDamage():
	var cnt = attack / attackInterval()
	var limit = data.units[name_]["amplifycountlimit"]
	cnt = int(clamp(cnt, 1, limit))
	return .attackDamage() * cnt

func Update():
	Decayable.TakeDecayDamage()
	if freeze > 0:
		attack = 0
		targetId = 0
		freeze -= 1
		return
	var t = target()
	if t == null || not withinRange(t):
		attack = 0
		setTarget(findTarget())
		t = target()
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
		var r = float(attackDamage()) / damage_max
		beam.scale.x = r * (beam_width_max - beam_width_min) + beam_width_min
		beam.modulate = beam_color_min.linear_interpolate(beam_color_max, r)
		if $Sound/Attack.playing == false:
			$Sound/Attack.play()

func target():
	return game.FindUnit(targetId)

func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()
