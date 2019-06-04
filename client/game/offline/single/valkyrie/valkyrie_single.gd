extends "res://game/unit/valkyrie/valkyrie.gd"


var attackInterval = 1

func Init(id, level, posX, posY, game, player):
	.Init(id, level, posX, posY, game, player)
	body.no_physics = true

func Update():
	attack += 1
	if attack == attackInterval:
		fire()
		attack = 0

func fire():
	var b = $ResourcePreloader.get_resource("bullet").instance()
	b.Init(0, 25, 30, "Bullet", game)
	game.AddBullet(b)
	
	# client only
	b.rotation = $Rotatable.rotation
	b.global_position = $Rotatable/Body/Missile.global_position
