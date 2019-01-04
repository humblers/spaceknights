extends "res://game/script/unit.gd"

export(float) var absorb_max_scale = 2.3
export(float) var absorb_min_scale = 0.8
export(NodePath) onready var absorb_node = get_node(absorb_node)

# invariant
var absorb_max

var player
var targetId = 0
var attack = 0
var absorbed = 0

func _process(delta):
	if absorb_max == null:
		return
	var s = float(absorbed) / absorb_max * (absorb_max_scale - absorb_min_scale) + absorb_min_scale
	absorb_node.scale = Vector2(s, s)

func Init(id, level, posX, posY, game, player):
	New(id, "absorber", player.Team(), level, posX, posY, game)
	self.player = player
	absorb_max = hp * absorbRatio() / 100

func TakeDamage(amount, damageType, attacker):
	.TakeDamage(amount, damageType, attacker)
	absorbed += amount * absorbRatio() / 100

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
		$AnimationPlayer.play("attack")
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			var damage = attackDamage() + absorbed
			absorbed = 0
			for id in game.UnitIds():
				var u = game.FindUnit(id)
				if not canAttack(u):
					continue
				var x = scalar.Sub(PositionX(), u.PositionX())
				var y = scalar.Sub(PositionY(), u.PositionY())
				var d = vector.LengthSquared(x, y)
				var r = scalar.Add(u.Radius(), attackRadius())
				if d < scalar.Mul(r, r):
					u.TakeDamage(damage, damageType(), self)
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func canAttack(unit):
	if Team() == unit.Team():
		return false
	if not targetTypes().has(unit.Type()):
		return false
	return true

func attackRadius():
	var r = data.units[name_]["attackradius"]
	return game.World().FromPixel(r)

func absorbRatio():
	return data.units[name_]["absorbratio"]