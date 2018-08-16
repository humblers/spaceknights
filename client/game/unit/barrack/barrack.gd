extends "res://game/script/unit.gd"

var Decayable = preload("res://game/script/decayable.gd")
var TileOccupier = preload("res://game/script/tileoccupier.gd")

var spawn = 0
var player

func InitDummy(posX, posY, game, player):
	.InitDummy("barrack", player.Team(), posX, posY, game)

func Init(id, level, posX, posY, game, player):
	.Init(id, "barrack", player.Team(), level, posX, posY, game)
	Decayable = Decayable.new()
	Decayable.Init(self)
	TileOccupier = TileOccupier.new()
	TileOccupier.Init(game)
	self.player = player

func Destroy():
	.Destroy()
	$AnimationPlayer.play("explosion")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func Update():
	Decayable.TakeDecayDamage()
	var step = spawn % spawnInterval()
	if step == 0:
		$AnimationPlayer.play("spawn-anchor")
	if step == 15:
		doSpawn()
	spawn += 1

func spawnInterval():
	stat.units[name_]["spawninterval"]

func doSpawn():
	var card = stat.units[name_]
	var name = card["spawn"]
	var count = card["spawncount"]
	var offsetX = card["spawnoffsetX"]
	var offsetY = card["spawnoffsetY"]
	var posX = game.World().ToPixel(PositionX())
	var posY = game.World().ToPixel(PositionY())
	for i in range(count):
		game.AddUnit(name, level, posX+offsetX[i], posY+offsetY[i], player)
