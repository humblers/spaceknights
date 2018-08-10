extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0

func InitDummy(posX, posY, game, player):
	.InitDummy("shadowvision", player.Team(), posX, posY, game)

func Init(id, level, posX, posY, game, player):
	.Init(id, "shadowvision", player.Team(), level, posX, posY, game)
	set_process(true)
	$Rotatable/Main/Shade/Left.show()
	$Rotatable/Main/Shade/Right.show()
	$Rotatable/Main/Shade/Front.show()
	$Rotatable/Main/Shade/Rear.show()

func _process(delta):
	var shade = $Rotatable/Main/Shade
	var angle = game.MAIN_LIGHT_ANGLE - $Rotatable.rotation_degrees
	var t1 = 1 - clamp(abs(angle_diff(0, angle)) / 90, 0, 1)
	var t2 = 1 - clamp(abs(angle_diff(90, angle)) / 90, 0, 1)
	var t3 = 1 - clamp(abs(angle_diff(180, angle)) / 90, 0, 1)
	var t4 = 1 - clamp(abs(angle_diff(270, angle)) / 90, 0, 1)
	shade.get_node("Right").modulate = Color(0, 0, 0, t1)
	shade.get_node("Front").modulate = Color(0, 0, 0, t2)
	shade.get_node("Left").modulate = Color(0, 0, 0, t3)
	shade.get_node("Rear").modulate = Color(0, 0, 0, t4)
	shade.get_node("Right/Light2D").energy = 1.5 * t1
	shade.get_node("Front/Light2D").energy = 1.5 * t2
	shade.get_node("Left/Light2D").energy = 1.5 * t3
	shade.get_node("Rear/Light2D").energy = 1.5 * t4

func angle_diff(a, b):
	return fposmod((a - b) + 180, 360) - 180
	

func Update():
	SetVelocity(0, 0)
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

func fire():
	var b = resource.BULLET[name_].instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), game)
	game.AddBullet(b)
	# client only
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
	look_at(unit.PositionX(), unit.PositionY())
	if $AnimationPlayer.current_animation != "move" or not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("move")
	

func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
		setLayer("Normal")
	var t = target()
	if t != null:
		look_at(t.PositionX(), t.PositionY())
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