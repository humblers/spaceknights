extends Node2D

var targetId = 0
var lifetime = 0
var damage = 0
var damageType
var slowDuration = 0
var game

func Init(targetId, lifetime, damage, damageType, game):
	self.targetId = targetId
	self.lifetime = lifetime
	self.damage = damage
	self.damageType = damageType
	self.game = game

func Update():
	if lifetime <= 0:
		var target = game.FindUnit(targetId)
		if target != null:
			target.TakeDamage(damage, self)
			target.MakeSlow(slowDuration)
	lifetime -= 1

func IsExpired():
	return lifetime < 0

func Destroy():
	queue_free()

func DamageType():
	return damageType

func MakeFrozen(slowDuration):
	self.slowDuration = slowDuration

func _process(delta):
	if lifetime > 0:
		var target = game.FindUnit(targetId)
		if target != null:
			var lifetimesec = float(lifetime)/game.STEP_PER_SEC
			var remain = target.position - position
			position += remain * (delta/lifetimesec)
			rotation = PI/2 + remain.angle()
			return
	hide()