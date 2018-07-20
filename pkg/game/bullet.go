package game

type Bullet interface {
	Update(g Game)
	IsExpired() bool
}

type bullet struct {
	targetId int
	lifetime int
	damage   int
}

func newBullet(targetId int, lifetime int, damage int) Bullet {
	return &bullet{
		targetId: targetId,
		lifetime: lifetime,
		damage:   damage,
	}
}

func (b *bullet) Update(g Game) {
	if b.lifetime <= 0 {
		target := g.FindUnit(b.targetId)
		if target != nil {
			target.TakeDamage(b.damage)
		}
	}
	b.lifetime--
}

func (b *bullet) IsExpired() bool {
	return b.lifetime <= 0
}
