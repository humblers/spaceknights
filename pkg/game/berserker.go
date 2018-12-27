package game

type berserker struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newBerserker(id int, level, posX, posY int, g Game, p Player) Unit {
	return &berserker{
		unit: newUnit(id, "berserker", p.Team(), level, posX, posY, g),
	}
}

func (b *berserker) Update() {
	b.unit.Update()
	if b.freeze > 0 {
		b.attack = 0
		b.targetId = 0
		b.freeze--
		return
	}
	if b.attack > 0 {
		b.handleAttack()
	} else {
		t := b.target()
		if t == nil {
			b.findTargetAndDoAction()
		} else {
			if b.withinRange(t) {
				b.handleAttack()
			} else {
				b.findTargetAndDoAction()
			}
		}
	}
}

func (b *berserker) target() Unit {
	return b.game.FindUnit(b.targetId)
}

func (b *berserker) setTarget(u Unit) {
	if u == nil {
		b.targetId = 0
	} else {
		b.targetId = u.Id()
	}
}

func (b *berserker) findTargetAndDoAction() {
	t := b.findTarget()
	b.setTarget(t)
	if t != nil {
		if b.withinRange(t) {
			b.handleAttack()
		} else {
			b.moveTo(t)
		}
	}
}

func (b *berserker) handleAttack() {
	if b.attack == b.preAttackDelay() {
		t := b.target()
		if t != nil && b.withinRange(t) {
			t.TakeDamage(b.attackDamage(), b.damageType())
		} else {
			b.attack = 0
			return
		}
	}
	b.attack++
	if b.attack > b.attackInterval() {
		b.attack = 0
	}
}
