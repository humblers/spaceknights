package game

import "github.com/humblers/spaceknights/pkg/fixed"

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
	j.charge = 0
}

func (j *jouster) moveTo(u Unit) {
	corner := j.game.Map().FindNextCornerInPath(
		j.Position(),
		u.Position(),
		j.Radius(),
	)
	direction := corner.Sub(j.Position()).Normalized()
	speed := j.speed()
	if j.charged() {
		speed = j.chargedMoveSpeed()
	}
	j.SetVelocity(direction.Mul(speed))
	j.charge++
}

func (j *jouster) handleAttack() {
	if j.charged() {
		if j.attack == j.chargedAttackPreDelay() {
			t := j.target()
			if t != nil && j.withinRange(t) {
				t.TakeDamage(j.chargedAttackDamage(), Melee)
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
}

func (j *jouster) chargeDelay() int {
	return units[j.name]["chargedelay"].(int)
}

func (j *jouster) chargedMoveSpeed() fixed.Scalar {
	s := units[j.name]["chargedmovespeed"].(int)
	return j.game.World().FromPixel(s)
}

func (j *jouster) chargedAttackDamage() int {
	switch v := units[j.name]["chargedattackdamage"].(type) {
	case int:
		return v
	case []int:
		return v[j.level]
	}
	panic("invalid charged attack damage type")
}

func (j *jouster) chargedAttackInterval() int {
	return units[j.name]["chargedattackinterval"].(int)
}

func (j *jouster) chargedAttackPreDelay() int {
	return units[j.name]["chargedattackpredelay"].(int)
}

func (j *jouster) charged() bool {
	return j.charge >= j.chargeDelay()
}
