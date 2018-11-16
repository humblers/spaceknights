package game

type footman struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newFootman(id int, level, posX, posY int, g Game, p Player) Unit {
	return &footman{
		unit: newUnit(id, "footman", p.Team(), level, posX, posY, g),
	}
}

func (f *footman) Update() {
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

func (f *footman) target() Unit {
	return f.game.FindUnit(f.targetId)
}

func (f *footman) setTarget(u Unit) {
	if u == nil {
		f.targetId = 0
	} else {
		f.targetId = u.Id()
	}
}

func (f *footman) findTargetAndDoAction() {
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

func (f *footman) handleAttack() {
	if f.attack == f.preAttackDelay() {
		t := f.target()
		if t != nil && f.withinRange(t) {
			t.TakeDamage(f.attackDamage(), f)
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
