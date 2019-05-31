package game

type felhound struct {
	*unit
	targetId int
	attack   int
}

func newFelhound(id int, level, posX, posY int, g Game, p Player) Unit {
	return &felhound{
		unit: newUnit(id, "felhound", p.Team(), level, posX, posY, g),
	}
}

func (f *felhound) Update() {
	f.unit.Update()
	if f.freeze > 0 {
		f.attack = 0
		f.targetId = 0
		f.freeze--
		return
	}
	if f.attack > 0 {
		f.handleAttack()
	} else {
		t := f.target()
		if t == nil {
			f.findTargetAndDoAction()
		} else {
			if f.withinRange(t) {
				f.handleAttack()
			} else {
				f.findTargetAndDoAction()
			}
		}
	}
}

func (f *felhound) target() Unit {
	return f.game.FindUnit(f.targetId)
}

func (f *felhound) setTarget(u Unit) {
	if u == nil {
		f.targetId = 0
	} else {
		f.targetId = u.Id()
	}
}

func (f *felhound) findTargetAndDoAction() {
	t := f.findTarget()
	f.setTarget(t)
	if t != nil {
		if f.withinRange(t) {
			f.handleAttack()
		} else {
			f.moveTo(t)
		}
	}
}

func (f *felhound) handleAttack() {
	if f.attack == f.preAttackDelay() {
		t := f.target()
		if t != nil && f.withinRange(t) {
			t.TakeDamage(f.attackDamage(), f.damageType())
		} else {
			f.attack = 0
			return
		}
	}
	f.attack++
	if f.attack > f.attackInterval() {
		f.attack = 0
	}
}
