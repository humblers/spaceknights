package game

type Decayable interface {
	TakeDecayDamage()
	SetDecayOff()
}

type decayable struct {
	Unit
	off bool
}

func newDecayable(u Unit) *decayable {
	return &decayable{
		Unit: u,
	}
}

func (d *decayable) TakeDecayDamage() {
	if d.off {
		return
	}
	damage := units[d.Name()]["decaydamage"].(int)
	d.TakeDamage(damage, Self)
}

func (d *decayable) SetDecayOff() {
	d.off = true
}
