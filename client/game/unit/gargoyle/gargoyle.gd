extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var shield

func Init(id, level, posX, posY, game, player):
	New(id, "gargoyle", player.Team(), level, posX, posY, game)
	shield = initialShield()
	$Hp/Shield.max_value = shield
	$Hp/Shield.value = shield

func TakeDamage(amount, attackType):
	if attackType != "Melee":
		shield -= amount
		if shield < 0:
			hp += shield
			shield = 0
		$Energyshield/AnimationPlayer.play("energyshield")
	else:
		hp -= amount
		if attackType != "Self":
			damages[game.step] = 0
	$Hp/Shield.value = shield
	node_hp.value = hp
	node_hp.visible = true
	$Hp/Shield.visible = true

func Update():
	SetVelocity(0, 0)
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
	shield += stat.ShieldRegenPerStep
	if shield > initialShield():
		shield = initialShield()
	$Hp/Shield.value = shield

func Destroy():
	.Destroy()
	$AnimationPlayer.play("explosion")
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

func moveTo(unit):
	var corner = game.Map().FindNextCornerInPath(
		PositionX(), PositionY(),
		unit.PositionX(), unit.PositionY(),
		Radius())
	var x = scalar.Sub(corner[0], PositionX())
	var y = scalar.Sub(corner[1], PositionY())
	var direction = vector.Normalized(x, y)
	var speed = speed()
	SetVelocity(
		scalar.Mul(direction[0], speed),
		scalar.Mul(direction[1], speed))
	look_at_pos(corner[0], corner[1])
	if $AnimationPlayer.current_animation != "move" or not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("move")

func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
		$Sound/sound_fire.play()
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			t.TakeDamage(attackDamage(), "Melee")
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0