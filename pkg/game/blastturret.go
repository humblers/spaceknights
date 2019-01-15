package game

import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type blastturret struct {
	*unit
	player Player
	Decayable
	targetId int
	attack   int // elapsed time since attack start
}

func newBlastturret(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "blastturret", p.Team(), level, posX, posY, g)
	b := &blastturret{
		unit:   u,
		player: p,
	}
	b.Decayable = newDecayable(b)
	return b
}

func (b *blastturret) TakeDamage(amount int, damageType data.DamageType) {
	if damageType.Is(data.DecreaseOnKnight) {
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	}
	b.unit.TakeDamage(amount, damageType)
}

func (b *blastturret) Destroy() {
	b.unit.Destroy()
	b.Release()
}

func (b *blastturret) Update() {
	b.TakeDecayDamage()
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

func (b *blastturret) target() Unit {
	return b.game.FindUnit(b.targetId)
}

func (b *blastturret) setTarget(u Unit) {
	if u == nil {
		b.targetId = 0
	} else {
		b.targetId = u.Id()
	}
}

func (b *blastturret) fire() {
	bullet := newBullet(b.targetId, b.bulletLifeTime(), b.attackDamage(), b.damageType(), b.game)
	bullet.MakeSplash(b.damageRadius())
	b.game.AddBullet(bullet)
}

func (b *blastturret) findTargetAndDoAction() {
	t := b.findTarget()
	b.setTarget(t)
	if t != nil {
		if b.withinRange(t) {
			b.handleAttack()
		}
	}
}

func (b *blastturret) handleAttack() {
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

func (b *blastturret) damageRadius() fixed.Scalar {
	r := data.Units[b.name]["damageradius"].(int)
	return b.game.World().FromPixel(r)
}
