package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type jouster struct {
	*unit
	targetId int
	attack   int
	charge   int
}

func newJouster(id int, level, posX, posY int, g Game, p Player) Unit {
	return &jouster{
		unit: newUnit(id, "jouster", p.Team(), level, posX, posY, g),
	}
}

func (j *jouster) Update() {
	j.SetVelocity(fixed.Vector{0, 0})
	if j.freeze > 0 {
		j.attack = 0
		j.targetId = 0
		j.charge = 0
		j.freeze--
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
	} else {
		j.charge = 0
	}
}

func (j *jouster) moveTo(u Unit) {
	j.unit.moveTo(u)
	j.charge++
}

func (j *jouster) handleAttack() {
	if j.charged() {
		if j.attack == j.chargedAttackPreDelay() {
			t := j.target()
			if t != nil && j.withinRange(t) {
				t.TakeDamage(j.chargedAttackDamage(), j)
			} else {
				j.attack = 0
				j.charge = 0
				return
			}
		}
		j.attack++
		if j.attack > j.chargedAttackInterval() {
			j.attack = 0
			j.charge = 0
		}
	} else {
		j.charge = 0
		if j.attack == j.preAttackDelay() {
			t := j.target()
			if t != nil && j.withinRange(t) {
				t.TakeDamage(j.attackDamage(), j)
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
}

func (j *jouster) chargeDelay() int {
	return data.Units[j.name]["chargedelay"].(int)
}

func (j *jouster) chargedMoveSpeed() fixed.Scalar {
	s := data.Units[j.name]["chargedmovespeed"].(int)
	return j.game.World().FromPixel(s)
}

func (j *jouster) chargedAttackDamage() int {
	switch v := data.Units[j.name]["chargedattackdamage"].(type) {
	case int:
		return v
	case []int:
		return v[j.level]
	}
	panic("invalid charged attack damage type")
}

func (j *jouster) chargedAttackInterval() int {
	return data.Units[j.name]["chargedattackinterval"].(int)
}

func (j *jouster) chargedAttackPreDelay() int {
	return data.Units[j.name]["chargedattackpredelay"].(int)
}

func (j *jouster) charged() bool {
	return j.charge >= j.chargeDelay()
}
