package game

import "github.com/humblers/spaceknights/pkg/fixed"

type berserker struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newBerserker(id int, level, posX, posY int, g Game, p Player) Unit {
	return &berserker{
		unit: newUnit(id, "berserker", p.Team(), level, posX, posY, g),
	}
}

func (b *berserker) Update() {
	b.SetVelocity(fixed.Vector{0, 0})
	if b.attack > 0 {
		b.handleAttack()
	} else {
		t := b.target()
		if t == nil {
			b.findTargetAndDoAction()
		} else {
			if b.withinRange(t) {
				b.handleAttack()
			} else {
				b.findTargetAndDoAction()
			}
		}
	}
}

func (b *berserker) target() Unit {
	return b.game.FindUnit(b.targetId)
}

func (b *berserker) setTarget(u Unit) {
	if u == nil {
		b.targetId = 0
	} else {
		b.targetId = u.Id()
	}
}

func (b *berserker) findTargetAndDoAction() {
	t := b.findTarget()
	b.setTarget(t)
	if t != nil {
		if b.withinRange(t) {
			b.handleAttack()
		} else {
			b.moveTo(t)
		}
	}
}

func (b *berserker) moveTo(u Unit) {
	corner := b.game.Map().FindNextCornerInPath(
		b.Position(),
		u.Position(),
		b.Radius(),
	)
	direction := corner.Sub(b.Position()).Normalized()
	b.SetVelocity(direction.Mul(b.speed()))
}

func (b *berserker) handleAttack() {
	if b.attack == b.preAttackDelay() {
		t := b.target()
		if t != nil && b.withinRange(t) {
			t.TakeDamage(b.attackDamage(), Melee)
		} else {
			b.attack = 0
			return
		}
	}
	b.attack++
	if b.attack > b.attackInterval() {
		b.attack = 0
	}
}