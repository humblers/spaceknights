package game

type Decayable interface {
	TakeDecayDamage()
}

type decayable struct {
	Unit
}

func newDecayable(u Unit) *decayable {
	return &decayable{
		Unit: u,
	}
}

func (d *decayable) TakeDecayDamage() {
	damage := units[d.Name()]["decaydamage"].(int)
	d.TakeDamage(damage, Self)
}
