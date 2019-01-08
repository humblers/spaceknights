extends "res://game/script/unit.gd"

var Decayable = preload("res://game/script/decayable.gd")

var spawn = 0
var player

func Init(id, level, posX, posY, game, player):
	New(id, "sentryshelter", player.Team(), level, posX, posY, game)
	Decayable = Decayable.new()
	Decayable.Init(self)
	self.player = player

func _ready():
	$Rotatable/Float/FloatAni.play("activate")

func TakeDamage(amount, damageType, attacker):
	if data.DamageTypeIs(damageType, data.DecreaseOnKnight):
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	.TakeDamage(amount, damageType, attacker)

func Destroy():
	.Destroy()
	.Release()
	$AnimationPlayer.play("destroy")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func Update():
	Decayable.TakeDecayDamage()
	if freeze > 0:
		freeze -= 1
		return
	var step = spawn % spawnInterval()
	if step == 0:
		$AnimationPlayer.play("spawn")
	if step == 10:
		doSpawn()
	spawn += 1

func spawnInterval():
	return data.units[name_]["spawninterval"]

func doSpawn():
	var card = data.units[name_]
	var name = card["spawn"]
	var count = card["spawncount"]
	var offsetX = card["spawnoffsetX"]
	var offsetY = card["spawnoffsetY"]
	var posX = game.World().ToPixel(PositionX())
	var posY = game.World().ToPixel(PositionY())
	for i in range(count):
		game.AddUnit(name, level, posX+offsetX[i], posY+offsetY[i], player)
