extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	New(id, "giant", player.Team(), level, posX, posY, game)

func Update():
	.Update()
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

func findTargetAndDoAction():
	var t = findTarget()
	setTarget(t)
	if t != null:
		if withinRange(t):
			handleAttack()
		else:
			moveTo(t)

func handleAttack():
	if attack == 0 and $AnimationPlayer.current_animation != "attack": 
		$AnimationPlayer.play("attack")
		if $Sound/Attack.playing == false:
			$Sound/Attack.play()
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			t.TakeDamage(attackDamage(), self)
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0
