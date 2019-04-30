extends "res://game/unit/judge/judge.gd"

func damageType():
	return data.units[name_]["damagetype"] & ~data.AntiShield

func TakeDamage(amount, damageType, attacker):
	if game.IsKnightInvincible():
		amount = 0
	.TakeDamage(amount, damageType, attacker)