package game

type Bullet interface {
	Update()
	IsExpired() bool
}

type bullet struct {
	targetId     int
	lifetime     int
	damage       int
	slowDuration int
	game         Game
}

func newBullet(targetId int, lifetime int, damage int, game Game) Bullet {
	return &bullet{
		targetId: targetId,
		lifetime: lifetime,
		damage:   damage,
		game:     game,
	}
}

func (b *bullet) Update() {
	if b.lifetime <= 0 {
		target := b.game.FindUnit(b.targetId)
		if target != nil {
			target.TakeDamage(b.damage, Range)
			target.MakeSlow(b.slowDuration)
		}
	}
	b.lifetime--
}

func (b *bullet) IsExpired() bool {
	return b.lifetime < 0
}

func (b *bullet) MakeFrozen(slowDuration int) {
	b.slowDuration = slowDuration
}
