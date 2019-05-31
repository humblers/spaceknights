extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var attack_counter = 0
var shield

func Init(id, level, posX, posY, game, player):
	New(id, "trainee", player.Team(), level, posX, posY, game)
	shield = initialShield()
	$Hp/HBoxContainer/VBoxContainer/Shield.max_value = shield
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield
	
func TakeDamage(amount, damageType, attacker):
	if not data.DamageTypeIs(damageType, data.AntiShield):
		shield -= amount
		if shield < 0:
			hp += shield
			shield = 0
			damages[game.step] = 0
			$HitEffect.hit(damageType)
		else:
			$Energyshield.hit(attacker)
	else:
		hp -= amount
		damages[game.step] = 0
		$HitEffect.hit(damageType)
	var node_hp = get_node("Hp/HBoxContainer/VBoxContainer/%s" % color)
	node_hp.value = hp
	node_hp.visible = true
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield
	$Hp/HBoxContainer/VBoxContainer/Shield.visible = true
	$Hp/HBoxContainer/Control.visible = true

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
	shield += data.ShieldRegenPerStep
	if shield > initialShield():
		shield = initialShield()
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield

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
	else:
		$AnimationPlayer.play("idle")

func handleAttack():
	if attack == 0:
		if attack_counter % 2 == 0:
			$AnimationPlayer.play("attack_1")
		else:
			$AnimationPlayer.play("attack_2")
		attack_counter += 1
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			t.TakeDamage(attackDamage(), damageType(), self)
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0
