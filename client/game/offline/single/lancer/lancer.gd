extends "res://game/unit/lancer/lancer.gd"

var attackInterval = 2
var rival

func Update():
	look_at_pos(rival.PositionX(), rival.PositionY())
	attack += 1
	if attack == attackInterval:
		fire()
		attack = 0
	
func fire():
	var b = $ResourcePreloader.get_resource("bullet").instance()
	b.Init(team, 25, 100, data.units["archer"]["damagetype"], game)
	game.AddBullet(b)
	
	# client only
	b.rotation = $Rotatable.rotation
	b.global_position = $Rotatable/Shotpoint.global_position
	
func setRival(knight):
	rival = knight


	
	