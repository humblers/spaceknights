extends "res://game/script/unit.gd"

func InitDummy(name, team, posX, posY, game):
	.InitDummy(name, team, posX, posY, game)

func Init(id, name, team, level, posX, posY, game):
	.Init(id, name, team, level, posX, posY, game)

func TakeDecayDamage():
	var damage = stat.units[name_]["decaydamage"]
	.TakeDamage(damage, "Self")