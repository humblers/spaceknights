extends "res://game/script/unit.gd"

var Decayable = preload("res://game/script/decayable.gd")
var TileOccupier = preload("res://game/script/tileoccupier.gd")

var targetId = 0
var attack = 0

var attackDelta = 0

func InitDummy(posX, posY, game, player):
	.InitDummy("cannon", player.Team(), posX, posY, game)

func Init(id, level, posX, posY, game, player):
	.Init(id, "cannon", player.Team(), level, posX, posY, game)
	Decayable = Decayable.new()
	Decayable.Init(self)
	TileOccupier = TileOccupier.new()
	TileOccupier.Init(game)

func Update():
	Decayable.TakeDecayDamage()
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
	$AnimationPlayer.play("explosion")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func addHp(amount):
	hp += amount

func addAttack(amount):
	attackDelta += amount

func attackDamage():
	return .attackDamage() + attackDelta

func target():
	return game.FindUnit(targetId)

func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()

func fire():
	var b = resource.BULLET[name_].instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), game)
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
		look_at(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0