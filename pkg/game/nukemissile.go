package game

import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type nukemissile struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newNukemissile(id int, level, posX, posY int, g Game, p Player) Unit {
	return &nukemissile{
		unit: newUnit(id, "nukemissile", p.Team(), level, posX, posY, g),
	}
}

func (n *nukemissile) TakeDamge(amount int, damageType data.DamageType) {
	alreadyDead := n.IsDead()
	n.unit.TakeDamage(amount, damageType)
	if !alreadyDead && n.IsDead() && n.attack > 0 && n.attack <= n.preAttackDelay() {
		n.suicideAttack()
		n.attack = n.preAttackDelay() + 1
	}
}

func (n *nukemissile) Update() {
	n.unit.Update()
	if n.attack > 0 {
		n.handleAttack()
	} else {
		if n.freeze > 0 {
			n.targetId = 0
			n.freeze--
			return
		}
		t := n.target()
		if t == nil {
			n.findTargetAndDoAction()
		} else {
			if n.withinRange(t) {
				n.handleAttack()
			} else {
				n.findTargetAndDoAction()
			}
		}
	}
}

func (n *nukemissile) target() Unit {
	return n.game.FindUnit(n.targetId)
}

func (n *nukemissile) setTarget(u Unit) {
	if u == nil {
		n.targetId = 0
	} else {
		n.targetId = u.Id()
	}
}

func (n *nukemissile) findTargetAndDoAction() {
	t := n.findTarget()
	n.setTarget(t)
	if t != nil {
		if n.withinRange(t) {
			n.handleAttack()
		} else {
			n.moveTo(t)
		}
	}
}

func (n *nukemissile) suicideAttack() {
	for _, id := range n.game.UnitIds() {
		u := n.game.FindUnit(id)
		if u.Team() == n.Team() {
			continue
		}
		d := n.Position().Sub(u.Position()).LengthSquared()
		r := u.Radius().Add(n.attackRadius())
		if d < r.Mul(r) {
			u.TakeDamage(n.attackDamage(), n.damageType())
		}
	}
	if !n.IsDead() {
		n.hp = 0
	}
}

func (n *nukemissile) handleAttack() {
	if n.attack == n.preAttackDelay() {
		n.suicideAttack()
	}
	n.attack++
}

func (n *nukemissile) attackRadius() fixed.Scalar {
	r := data.Units[n.name]["attackradius"].(int)
	return n.game.World().FromPixel(r)
}
