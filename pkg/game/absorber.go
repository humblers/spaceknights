package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type absorber struct {
	*unit
	player   Player
	targetId int
	attack   int
	absorbed int
}

func newAbsorber(id int, level, posX, posY int, g Game, p Player) Unit {
	return &absorber{
		unit:   newUnit(id, "absorber", p.Team(), level, posX, posY, g),
		player: p,
	}
}

func (a *absorber) TakeDamage(amount int, damageType data.DamageType) {
	a.unit.TakeDamage(amount, damageType)
	if !damageType.Is(data.Melee) {
		a.absorbed += amount * a.absorbRatio() / 100
	}
}

func (a *absorber) Update() {
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

func (a *absorber) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *absorber) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *absorber) findTargetAndDoAction() {
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

func (a *absorber) handleAttack() {
	if a.attack == a.preAttackDelay() {
		t := a.target()
		if t != nil && a.withinRange(t) {
			damage := a.attackDamage() + a.absorbed
			a.absorbed = 0
			for _, id := range a.game.UnitIds() {
				u := a.game.FindUnit(id)
				if !a.canAttack(u) {
					continue
				}
				d := a.Position().Sub(u.Position()).LengthSquared()
				r := u.Radius().Add(a.attackRadius())
				if d < r.Mul(r) {
					u.TakeDamage(damage, a.damageType())
				}
			}
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

func (a *absorber) canAttack(u Unit) bool {
	if a.Team() == u.Team() {
		return false
	}
	if !a.targetTypes().Contains(u.Type()) {
		return false
	}
	return true
}

func (a *absorber) attackRadius() fixed.Scalar {
	r := data.Units[a.name]["attackradius"].(int)
	return a.game.World().FromPixel(r)
}

func (a *absorber) absorbRatio() int {
	return data.Units[a.name]["absorbratio"].(int)
}
