package game

import "github.com/humblers/spaceknights/pkg/data"

type Bullet interface {
	Update()
	IsExpired() bool
	MakeFrozen(slowDuration int)
}

type bullet struct {
	targetId     int
	lifetime     int
	damage       int
	damageType   data.DamageType
	slowDuration int
	game         Game
}

func newBullet(targetId, lifetime, damage int, damageType data.DamageType, game Game) Bullet {
	return &bullet{
		targetId:   targetId,
		lifetime:   lifetime,
		damage:     damage,
		damageType: damageType,
		game:       game,
	}
}

func (b *bullet) Update() {
	if b.lifetime <= 0 {
		target := b.game.FindUnit(b.targetId)
		if target != nil {
			target.TakeDamage(b.damage, b)
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

func (b *bullet) DamageType() data.DamageType {
	return b.damageType
}
