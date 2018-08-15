package game

type Decayable interface {
	TakeDecayDamage()
}

type decayable struct {
	*unit
}

func newDecayable(u *unit) *decayable {
	return &decayable{
		unit: u,
	}
}

func (d *decayable) TakeDecayDamage() {
	damage := units[d.name]["decaydamage"].(int)
	d.TakeDamage(damage, Self)
}
