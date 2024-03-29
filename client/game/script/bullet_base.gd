extends Node2D

var targetId = 0
var lifetime = 0
var damage = 0
var damageType
var slowDuration = 0
var game

# for splash attack
var targetTeam = ""
var damageRadius = 0
var lastTargetPositionX
var lastTargetPositionY

func State():
	return {
		"targetId": targetId,
		"lifetime": lifetime,
		"damage": damage,
		"damageType": damageType,
		"slowDuration": slowDuration,
		"targetTeam": targetTeam,
		"damageRadius": damageRadius,
		"lastTargetPosition": {"X": lastTargetPositionX, "Y": lastTargetPositionY},
	}
	
func Hash():
	return djb2.Combine([
		djb2.HashInt(targetId),
		djb2.HashInt(lifetime),
		djb2.HashInt(damage),
		djb2.HashInt(damageType),
		djb2.HashInt(slowDuration),
		djb2.HashString(targetTeam),
		scalar.Hash(damageRadius),
		vector.Hash(lastTargetPositionX, lastTargetPositionY)
	])

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
				target.TakeDamage(damage, damageType, self)
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
					u.TakeDamage(damage, damageType, self)
					u.MakeSlow(slowDuration)
	lifetime -= 1

func IsExpired():
	return lifetime < 0

func MakeFrozen(slowDuration):
	self.slowDuration = slowDuration

func MakeSplash(radius):
	var target = game.FindUnit(targetId)
	targetTeam = target.Team()
	damageRadius = radius
