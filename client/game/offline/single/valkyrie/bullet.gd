extends "res://game/script/bullet_base.gd"

var team

func Init(team, lifetime, damage, damageType, game):
	self.team = team
	self.lifetime = lifetime
	self.damage = damage
	self.damageType = damageType
	self.game = game

func Update():
	position += Vector2(0, -80).rotated(self.get_rotation())
	
	if lifetime < 0:
		return

	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.team == self.team:
			pass
		else:
			var d = position - u.position
			if u.Type() == data.Squire:
				if d.length() < 50:
					u.TakeDamage(damage, damageType, self)
					hide()
					lifetime = -1
			else:
				if d.length() < 50:
					u.TakeDamage(damage, damageType, self)
					hide()
					lifetime = -1
						
	lifetime -= 1	

func _process(delta):
	pass
	#hide()
	
	


func Destroy():
	queue_free()
#