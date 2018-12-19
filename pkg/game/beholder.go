package game

import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type beholder struct {
	*unit
	player Player
	Decayable
	targetId int
	attack   int // elapsed time since attack start
}

func newBeholder(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "beholder", p.Team(), level, posX, posY, g)
	b := &beholder{
		unit:   u,
		player: p,
	}
	b.Decayable = newDecayable(b)
	return b
}

func (b *beholder) Destroy() {
	b.unit.Destroy()
	b.Release()
}

func (b *beholder) Update() {
	b.TakeDecayDamage()
	if b.freeze > 0 {
		b.attack = 0
		b.targetId = 0
		b.freeze--
		return
	}
	if b.target() == nil {
		b.setTarget(b.findTarget())
		b.attack = 0
	}
	t := b.target()
	if t != nil {
		if b.withinRange(t) {
			if b.attack%b.attackInterval() == 0 {
				t.TakeDamage(b.attackDamage(), b)
			}
			b.attack++
		} else {
			b.attack = 0
		}
	} else {
		b.attack = 0
	}
}

func (b *beholder) target() Unit {
	return b.game.FindUnit(b.targetId)
}

func (b *beholder) setTarget(u Unit) {
	if u == nil {
		b.targetId = 0
	} else {
		b.targetId = u.Id()
	}
}