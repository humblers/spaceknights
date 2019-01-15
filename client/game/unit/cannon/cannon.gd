extends "res://game/script/unit.gd"

var Decayable = preload("res://game/script/decayable.gd")

var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	New(id, "cannon", player.Team(), level, posX, posY, game)
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
	if targetId == 0:
		$AnimationPlayer.play("idle")

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
	var b = $ResourcePreloader.get_resource("bullet").instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), damageType(), game)
	game.AddBullet(b)
	# client only
	b.global_position = $Rotatable/CannonBody/Gun/Shotpoint.global_position

func findTargetAndDoAction():
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
