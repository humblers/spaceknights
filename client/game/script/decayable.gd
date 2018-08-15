extends Node

var unit

func Init(unit):
	self.unit = unit

func TakeDecayDamage():
	var damage = stat.units[unit.Name()]["decaydamage"]
	unit.TakeDamage(damage, "Self")