extends Reference

var unit
var off = false

func Init(unit):
	self.unit = unit

func TakeDecayDamage():
	if off:
		return
	var damage = stat.units[unit.Name()]["decaydamage"]
	unit.TakeDamage(damage, self)

func SetDecayOff():
	off = true

func DamageType():
	return "Decay"