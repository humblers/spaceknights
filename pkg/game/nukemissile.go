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

func (n *nukemissile) Update() {
	n.unit.Update()
	if n.freeze > 0 {
		n.attack = 0
		n.targetId = 0
		n.freeze--
		return
	}
	if n.attack > 0 {
		n.handleAttack()
	} else {
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

func (n *nukemissile) handleAttack() {
	for _, id := range n.game.UnitIds() {
		u := n.game.FindUnit(id)
		if u.Team() == n.Team() {
			continue
		}
		d := n.Position().Sub(u.Position()).LengthSquared()
		r := n.Radius().Add(u.Radius()).Add(n.destroyRadius())
		if d < r.Mul(r) {
			u.TakeDamage(n.destroyDamage(), n)
		}
	}
	n.hp = 0
}

func (n *nukemissile) destroyDamage() int {
	return data.Units[n.name]["destroydamage"].([]int)[n.level]
}

func (n *nukemissile) destroyRadius() fixed.Scalar {
	r := data.Units[n.name]["destroyradius"].(int)
	return n.game.World().FromPixel(r)
}
