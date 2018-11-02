package game

import "github.com/humblers/spaceknights/pkg/fixed"

type blaster struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newBlaster(id int, level, posX, posY int, g Game, p Player) Unit {
	return &blaster{
		unit: newUnit(id, "blaster", p.Team(), level, posX, posY, g),
	}
}

func (b *blaster) Update() {
	b.SetVelocity(fixed.Vector{0, 0})
	if b.freeze > 0 {
		b.attack = 0
		b.targetId = 0
		b.freeze--
		return
	}
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

func (b *blaster) target() Unit {
	return b.game.FindUnit(b.targetId)
}

func (b *blaster) setTarget(u Unit) {
	if u == nil {
		b.targetId = 0
	} else {
		b.targetId = u.Id()
	}
}

func (bl *blaster) fire() {
	b := newBullet(bl.targetId, bl.bulletLifeTime(), bl.attackDamage(), bl.DamageType(), bl.game)
	bl.game.AddBullet(b)
}

func (b *blaster) findTargetAndDoAction() {
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

func (b *blaster) moveTo(u Unit) {
	corner := b.game.Map().FindNextCornerInPath(
		b.Position(),
		u.Position(),
		b.Radius(),
	)
	direction := corner.Sub(b.Position()).Normalized()
	b.SetVelocity(direction.Mul(b.speed()))
}

func (b *blaster) handleAttack() {
	if b.attack == b.preAttackDelay() {
		t := b.target()
		if t != nil && b.withinRange(t) {
			b.fire()
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
