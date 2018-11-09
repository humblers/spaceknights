extends Node2D

var targetId = 0
var lifetime = 0
var damage = 0
var damageType
var slowDuration = 0
var game

# for splash attack
var targetTeam
var damageRadius
var lastTargetPositionX
var lastTargetPositionY

func Init(targetId, lifetime, damage, damageType, game):
	self.targetId = targetId
	self.lifetime = lifetime
	self.damage = damage
	self.damageType = damageType
	self.game = game

func Update():
	var target = game.FindUnit(targetId)
	if target != null:
		lastTargetPositionX = target.PositionX()
		lastTargetPositionY = target.PositionY()
	if lifetime <= 0:
		if damageRadius == 0:
			if target != null:
				target.TakeDamage(damage, self)
				target.MakeSlow(slowDuration)
		else:
			for id in game.UnitIds():
				var u = game.FindUnit(id)
				if u.Team() != targetTeam:
					continue
				var x = scalar.Sub(lastTargetPositionX, u.PositionX())
				var y = scalar.Sub(lastTargetPositionY, u.PositionY())
				var d = vector.LengthSquared(x, y)
				var r = scalar.Add(u.Radius(), damageRadius)
				if d < scalar.Mul(r, r):
					u.TakeDamage(damage, self)
					u.MakeSlow(slowDuration)
	lifetime -= 1

func IsExpired():
	return lifetime < 0

func DamageType():
	return damageType

func MakeFrozen(slowDuration):
	self.slowDuration = slowDuration

func MakeSplash(radius):
	var target = game.FindUnit(targetId)
	targetTeam = target.Team()
	damageRadius = radius
