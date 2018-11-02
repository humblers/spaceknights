package game

type blastturret struct {
	*unit
	Decayable
	TileOccupier
	targetId int
	attack   int // elapsed time since attack start
}

func newBlastturret(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "blastturret", p.Team(), level, posX, posY, g)
	b := &blastturret{
		unit:         u,
		TileOccupier: newTileOccupier(g),
	}
	b.Decayable = newDecayable(b)
	return b
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
	bullet := newBullet(b.targetId, b.bulletLifeTime(), b.attackDamage(), b.DamageType(), b.game)
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
