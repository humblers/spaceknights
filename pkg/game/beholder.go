package game

import "github.com/humblers/spaceknights/pkg/data"

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

func (b *beholder) TakeDamage(amount int, damageType data.DamageType) {
	if damageType == data.Skill || damageType == data.Death {
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	}
	b.unit.TakeDamage(amount, damageType)
}

func (b *beholder) Destroy() {
	b.unit.Destroy()
	b.Release()
}

func (b *beholder) attackDamage() int {
	cnt := b.attack / b.attackInterval()
	limit := data.Units[b.name]["amplifycountlimit"].(int)
	if cnt < 1 {
		cnt = 1
	} else if cnt > limit {
		cnt = limit
	}
	return b.unit.attackDamage() * cnt
}

func (b *beholder) Update() {
	b.TakeDecayDamage()
	if b.freeze > 0 {
		b.attack = 0
		b.targetId = 0
		b.freeze--
		return
	}
	t := b.target()
	if t == nil || !b.withinRange(t) {
		b.attack = 0
		b.setTarget(b.findTarget())
		t = b.target()
	}
	if t != nil {
		if b.withinRange(t) {
			if b.attack%b.attackInterval() == 0 {
				t.TakeDamage(b.attackDamage(), b.damageType())
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
