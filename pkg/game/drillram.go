package game

type drillram struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newDrillram(id int, level, posX, posY int, g Game, p Player) Unit {
	return &drillram{
		unit: newUnit(id, "drillram", p.Team(), level, posX, posY, g),
	}
}

func (d *drillram) Update() {
	d.unit.Update()
	if d.freeze > 0 {
		d.attack = 0
		d.targetId = 0
		d.freeze--
		return
	}
	if d.attack > 0 {
		d.handleAttack()
	} else {
		t := d.target()
		if t == nil {
			d.findTargetAndDoAction()
		} else {
			if d.withinRange(t) {
				d.handleAttack()
			} else {
				d.findTargetAndDoAction()
			}
		}
	}
}

func (d *drillram) target() Unit {
	return d.game.FindUnit(d.targetId)
}

func (d *drillram) setTarget(u Unit) {
	if u == nil {
		d.targetId = 0
	} else {
		d.targetId = u.Id()
	}
}

func (d *drillram) findTargetAndDoAction() {
	t := d.findTarget()
	d.setTarget(t)
	if t != nil {
		if d.withinRange(t) {
			d.handleAttack()
		} else {
			d.moveTo(t)
		}
	}
}

func (d *drillram) handleAttack() {
	if d.attack == d.preAttackDelay() {
		t := d.target()
		if t != nil && d.withinRange(t) {
			t.TakeDamage(d.attackDamage(), d)
		} else {
			d.attack = 0
			return
		}
	}
	d.attack++
	if d.attack > d.attackInterval() {
		d.attack = 0
	}
}
