package game

import "github.com/humblers/spaceknights/pkg/data"

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
	damage := data.Units[d.Name()]["decaydamage"].(int)
	d.TakeDamage(damage, Self)
}

func (d *decayable) SetDecayOff() {
	d.off = true
}
