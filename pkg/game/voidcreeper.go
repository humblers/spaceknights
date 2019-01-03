package game

type voidcreeper struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newVoidcreeper(id int, level, posX, posY int, g Game, p Player) Unit {
	return &voidcreeper{
		unit: newUnit(id, "voidcreeper", p.Team(), level, posX, posY, g),
	}
}

func (v *voidcreeper) Update() {
	v.unit.Update()
	if v.freeze > 0 {
		v.attack = 0
		v.targetId = 0
		v.freeze--
		return
	}
	if v.attack > 0 {
		v.handleAttack()
	} else {
		t := v.target()
		if t == nil {
			v.findTargetAndDoAction()
		} else {
			if v.withinRange(t) {
				v.handleAttack()
			} else {
				v.findTargetAndDoAction()
			}
		}
	}
}

func (v *voidcreeper) target() Unit {
	return v.game.FindUnit(v.targetId)
}

func (v *voidcreeper) setTarget(u Unit) {
	if u == nil {
		v.targetId = 0
	} else {
		v.targetId = u.Id()
	}
}

func (v *voidcreeper) findTargetAndDoAction() {
	t := v.findTarget()
	v.setTarget(t)
	if t != nil {
		if v.withinRange(t) {
			v.handleAttack()
		} else {
			v.moveTo(t)
		}
	}
}

func (v *voidcreeper) handleAttack() {
	if v.attack == v.preAttackDelay() {
		t := v.target()
		if t != nil && v.withinRange(t) {
			t.TakeDamage(v.attackDamage(), v.damageType())
		} else {
			v.attack = 0
			return
		}
	}
	v.attack++
	if v.attack > v.attackInterval() {
		v.attack = 0
	}
}
