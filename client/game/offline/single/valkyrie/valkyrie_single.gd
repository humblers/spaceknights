extends "res://game/unit/valkyrie/valkyrie.gd"


var attackInterval = 2
var rival

func Init(id, level, posX, posY, game, player):
	.Init(id, level, posX, posY, game, player)
	body.no_physics = true

func Update():
	look_at_pos(rival.PositionX(), rival.PositionY())
	attack += 1
	if attack == attackInterval:
		fire()
		attack = 0
	SetPosition(game.World().FromPixel(int(self.global_position.x)), game.World().FromPixel(int(self.global_position.y))) 

func fire():
	var b = $ResourcePreloader.get_resource("bullet").instance()
	b.Init(team, 25, 100, data.units["archer"]["damagetype"], game)
	game.AddBullet(b)
	
	# client only
	b.rotation = $Rotatable.rotation
	b.global_position = $Rotatable/Body/Missile.global_position
	
func setRival(knight):
	rival = knight

