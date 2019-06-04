extends "res://game/script/bullet_base.gd"

#func Init(lifetime, damage, damageType, game):
#	self.lifetime = lifetime
#	self.damage = damage
#	self.damageType = damageType
#	self.game = game

func Update():
#	var target = game.FindUnit(targetId)
#	if target != null:
#		lastTargetPositionX = target.PositionX()
#		lastTargetPositionY = target.PositionY()
#	if lifetime <= 0:
#		if damageRadius == 0:
#			if target != null:
#				target.TakeDamage(damage, damageType, self)
#				target.MakeSlow(slowDuration)
#		else:
#			for id in game.UnitIds():
#				var u = game.FindUnit(id)
#				if u.Team() != targetTeam:
#					continue
#				var x = scalar.Sub(lastTargetPositionX, u.PositionX())
#				var y = scalar.Sub(lastTargetPositionY, u.PositionY())
#				var d = vector.LengthSquared(x, y)
#				var r = scalar.Add(u.Radius(), damageRadius)
#				if d < scalar.Mul(r, r):
#					u.TakeDamage(damage, damageType, self)
#					u.MakeSlow(slowDuration)

	for id in game.UnitIds():
		var u = game.FindUnit(id)
#		var x = scalar.Sub(lastTargetPositionX, u.PositionX())
#		var y = scalar.Sub(lastTargetPositionY, u.PositionY())
#		var d = vector.LengthSquared(x, y)
#		var r = scalar.Add(u.Radius(), damageRadius)
#		if d < scalar.Mul(r, r):
#			u.TakeDamage(damage, damageType, self)
#			u.MakeSlow(slowDuration)

	lifetime -= 1
	
	if lifetime > 0:
		position += Vector2(0, -80)
		return


func _process(delta):
	pass
	#hide()
	
	


func Destroy():
	queue_free()
#
#func _process(delta):
#	if lifetime > 0:
#		var target = game.FindUnit(targetId)
#		if target != null:
#			var lifetimesec = float(lifetime)/data.StepPerSec
#			var remain = target.position - position
#			position += remain * (delta/lifetimesec)
#			rotation = PI/2 + remain.angle()
#			return
#	hide()
#
