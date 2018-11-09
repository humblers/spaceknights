extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var shield
var player

func Init(id, level, posX, posY, game, player):
	New(id, "shadowvision", player.Team(), level, posX, posY, game)
	self.player = player
	shield = initialShield()
	$Hp/Shield.max_value = shield
	$Hp/Shield.value = shield
	
func TakeDamage(amount, attacker):
	if Layer() != "Normal":
		return
	if attacker.DamageType() != "AntiShield":
		shield -= amount
		if shield < 0:
			hp += shield
			shield = 0
			damages[game.step] = 0
			$HitEffect.hit(attacker)
		else:
			$Energyshield.hit(attacker)
	else:
		hp -= amount
		damages[game.step] = 0
		$HitEffect.hit(attacker)
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
	shield += stat.ShieldRegenPerStep
	if shield > initialShield():
		shield = initialShield()
	$Hp/Shield.value = shield

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

func fire():
	var b = $ResourcePreloader.get_resource("missile").instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), DamageType(), game)
	b.MakeSplash(damageRadius())
	game.AddBullet(b)
	b.global_position = $Rotatable/Shotpoint.global_position

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

func moveTo(unit):
	var x = scalar.Sub(unit.PositionX(), PositionX())
	var y = scalar.Sub(unit.PositionY(), PositionY())
	var direction = vector.Normalized(x, y)
	var speed = speed()
	SetVelocity(
		scalar.Mul(direction[0], speed), 
		scalar.Mul(direction[1], speed))
	look_at_pos(unit.PositionX(), unit.PositionY())
	if $AnimationPlayer.current_animation != "move" or not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("move")
	if $Sound/Move.playing == false:
		$Sound/Move.play()

func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
		setLayer("Normal")
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			setLayer(initialLayer())
			return
	attack += 1
	if attack > attackInterval():
		attack = 0
		setLayer(initialLayer())

func damageRadius():
	var r = stat.units[name_]["damageradius"]
	var divider = 1
	var ratios = player.StatRatios("arearatio")
	for i in range(len(ratios)):
		r *= ratios[i]
		divider *= 100
	return game.World().FromPixel(r / divider)