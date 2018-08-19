package game

import "github.com/humblers/spaceknights/pkg/fixed"

type jouster struct {
	*unit
	targetId          int
	attack            int
	transform         int
	transformToAttack bool
}

func newJouster(id int, level, posX, posY int, g Game, p Player) Unit {
	return &jouster{
		unit: newUnit(id, "jouster", p.Team(), level, posX, posY, g),
	}
}

func (j *jouster) Update() {
	j.SetVelocity(fixed.Vector{0, 0})
	if j.transform > 0 && j.transform < j.transformDelay() {
		if j.transformToAttack {
			j.transform++
		} else {
			j.transform--
		}
		return
	}
	if j.attack > 0 {
		j.handleAttack()
	} else {
		t := j.target()
		if t == nil {
			j.findTargetAndDoAction()
		} else {
			if j.withinRange(t) {
				j.handleAttack()
			} else {
				j.findTargetAndDoAction()
			}
		}
	}
}

func (j *jouster) target() Unit {
	return j.game.FindUnit(j.targetId)
}

func (j *jouster) setTarget(u Unit) {
	if u == nil {
		j.targetId = 0
	} else {
		j.targetId = u.Id()
	}
}

func (j *jouster) findTargetAndDoAction() {
	t := j.findTarget()
	j.setTarget(t)
	if t != nil {
		if j.withinRange(t) {
			j.handleAttack()
		} else {
			j.moveTo(t)
		}
	}
}

func (j *jouster) moveTo(u Unit) {
	if j.transform > 0 {
		j.transformToAttack = false
		j.transform--
		return
	}
	corner := j.game.Map().FindNextCornerInPath(
		j.Position(),
		u.Position(),
		j.Radius(),
	)
	direction := corner.Sub(j.Position()).Normalized()
	j.SetVelocity(direction.Mul(j.speed()))
}

func (j *jouster) handleAttack() {
	if j.transform < j.transformDelay() {
		j.transformToAttack = true
		j.transform++
		return
	}
	if j.attack == j.preAttackDelay() {
		t := j.target()
		if t != nil && j.withinRange(t) {
			t.TakeDamage(j.attackDamage(), Melee)
		} else {
			j.attack = 0
			return
		}
	}
	j.attack++
	if j.attack > j.attackInterval() {
		j.attack = 0
	}
}

func (j *jouster) transformDelay() int {
	return units[j.name]["transformdelay"].(int)
}
