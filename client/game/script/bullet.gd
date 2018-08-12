extends Node2D

var targetId = 0
var lifetime = 0
var damage = 0
var game

func Init(targetId, lifetime, damage, game):
	self.targetId = targetId
	self.lifetime = lifetime
	self.damage = damage
	self.game = game
	set_process(true)

func Update(game):
	if lifetime <= 0:
		var target = game.FindUnit(targetId)
		if target != null:
			target.TakeDamage(damage, "Range")
	lifetime -= 1

func IsExpired():
	return lifetime < 0

func Destroy():
	queue_free()
	
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