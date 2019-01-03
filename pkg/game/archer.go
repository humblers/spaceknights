package game

type archer struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newArcher(id int, level, posX, posY int, g Game, p Player) Unit {
	return &archer{
		unit: newUnit(id, "archer", p.Team(), level, posX, posY, g),
	}
}

func (a *archer) Update() {
	a.unit.Update()
	if a.freeze > 0 {
		a.attack = 0
		a.targetId = 0
		a.freeze--
		return
	}
	if a.attack > 0 {
		a.handleAttack()
	} else {
		t := a.target()
		if t == nil {
			a.findTargetAndDoAction()
		} else {
			if a.withinRange(t) {
				a.handleAttack()
			} else {
				a.findTargetAndDoAction()
			}
		}
	}
}

func (a *archer) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *archer) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *archer) fire() {
	b := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage(), a.damageType(), a.game)
	a.game.AddBullet(b)
}

func (a *archer) findTargetAndDoAction() {
	t := a.findTarget()
	a.setTarget(t)
	if t != nil {
		if a.withinRange(t) {
			a.handleAttack()
		} else {
			a.moveTo(t)
		}
	}
}

func (a *archer) handleAttack() {
	if a.attack == a.preAttackDelay() {
		t := a.target()
		if t != nil && a.withinRange(t) {
			a.fire()
		} else {
			a.attack = 0
			return
		}
	}
	a.attack++
	if a.attack > a.attackInterval() {
		a.attack = 0
	}
}
