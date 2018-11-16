package game

import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type blaster struct {
	*unit
	player   Player
	targetId int
	attack   int // elapsed time since attack start
}

func newBlaster(id int, level, posX, posY int, g Game, p Player) Unit {
	return &blaster{
		unit:   newUnit(id, "blaster", p.Team(), level, posX, posY, g),
		player: p,
	}
}

func (b *blaster) Update() {
	b.unit.Update()
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

func (b *blaster) fire() {
	bullet := newBullet(b.targetId, b.bulletLifeTime(), b.attackDamage(), b.DamageType(), b.game)
	bullet.MakeSplash(b.damageRadius())
	b.game.AddBullet(bullet)
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

func (b *blaster) damageRadius() fixed.Scalar {
	r := data.Units[b.name]["damageradius"].(int)
	divider := 1
	for _, ratio := range b.player.StatRatios("arearatio") {
		r *= ratio
		divider *= 100
	}
	return b.game.World().FromPixel(r / divider)
}
