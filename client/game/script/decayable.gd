extends Reference

var unit
var off = false

func Init(unit):
	self.unit = unit

func TakeDecayDamage():
	if off:
		return
	var damage = stat.units[unit.Name()]["decaydamage"]
	unit.TakeDamage(damage, "Self")

func SetDecayOff():
	off = true