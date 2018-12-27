package game

type trainee struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newTrainee(id int, level, posX, posY int, g Game, p Player) Unit {
	return &trainee{
		unit: newUnit(id, "trainee", p.Team(), level, posX, posY, g),
	}
}

func (tr *trainee) Update() {
	tr.unit.Update()
	if tr.freeze > 0 {
		tr.attack = 0
		tr.targetId = 0
		tr.freeze--
		return
	}
	if tr.attack > 0 {
		tr.handleAttack()
	} else {
		t := tr.target()
		if t == nil {
			tr.findTargetAndDoAction()
		} else {
			if tr.withinRange(t) {
				tr.handleAttack()
			} else {
				tr.findTargetAndDoAction()
			}
		}
	}
}

func (tr *trainee) target() Unit {
	return tr.game.FindUnit(tr.targetId)
}

func (tr *trainee) setTarget(u Unit) {
	if u == nil {
		tr.targetId = 0
	} else {
		tr.targetId = u.Id()
	}
}

func (tr *trainee) findTargetAndDoAction() {
	t := tr.findTarget()
	tr.setTarget(t)
	if t != nil {
		if tr.withinRange(t) {
			tr.handleAttack()
		} else {
			tr.moveTo(t)
		}
	}
}

func (tr *trainee) handleAttack() {
	if tr.attack == tr.preAttackDelay() {
		t := tr.target()
		if t != nil && tr.withinRange(t) {
			t.TakeDamage(tr.attackDamage(), tr.damageType())
		} else {
			tr.attack = 0
			return
		}
	}
	tr.attack++
	if tr.attack > tr.attackInterval() {
		tr.attack = 0
	}
}
