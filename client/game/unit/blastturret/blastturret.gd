extends "res://game/script/unit.gd"

var Decayable = preload("res://game/script/decayable.gd")

var targetId = 0
var attack = 0
var player

func Init(id, level, posX, posY, game, player):
	New(id, "blastturret", player.Team(), level, posX, posY, game)
	self.player = player
	Decayable = Decayable.new()
	Decayable.Init(self)

func _ready():
	$Float/FloatAni.play("activate")

func TakeDamage(amount, damageType, attacker):
	if data.DamageTypeIs(damageType, data.DecreaseOnKnight):
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	.TakeDamage(amount, damageType, attacker)

func Update():
	Decayable.TakeDecayDamage()
	if freeze > 0:
		attack = 0
		targetId = 0
		freeze -= 1
		return
	if attack > 0:
		handleAttack()
	else:
		var t = target()
		if t == null:
			findTargetAndDoAction()
		else:
			if withinRange(t):
				handleAttack()
			else:
				findTargetAndDoAction()

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

func fire():
	var b = $ResourcePreloader.get_resource("missile").instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), damageType(), game)
	b.MakeSplash(damageRadius())
	game.AddBullet(b)
	# client only
	b.rotation = $Rotatable.rotation
	b.global_position = $Rotatable/TurretBody/Launcher/Shotpoint.global_position

func findTargetAndDoAction():
	if !$AnimationPlayer.get_current_animation():
		$AnimationPlayer.play("idle")
	var t = findTarget()
	setTarget(t)
	if t != null:
		if withinRange(t):
			handleAttack()

func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func damageRadius():
	var r = data.units[name_]["damageradius"]
	return game.World().FromPixel(r)
