package game

import "github.com/humblers/spaceknights/pkg/djb2"
import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type Bullet interface {
	Update()
	IsExpired() bool
	MakeFrozen(slowDuration int)
	MakeSplash(radius fixed.Scalar)
	Hash() uint32
	State() map[string]interface{}
}

type bullet struct {
	targetId     int
	lifetime     int
	damage       int
	damageType   data.DamageType
	slowDuration int
	game         Game

	// for splash attack
	targetTeam         Team
	damageRadius       fixed.Scalar
	lastTargetPosition fixed.Vector
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

func (b *bullet) State() map[string]interface{} {
	return map[string]interface{}{
		"targetId":           b.targetId,
		"lifetime":           b.lifetime,
		"damage":             b.damage,
		"damageType":         b.damageType,
		"slowDuration":       b.slowDuration,
		"targetTeam":         b.targetTeam,
		"damageRadius":       b.damageRadius,
		"lastTargetPosition": b.lastTargetPosition,
	}
}

func (b *bullet) Hash() uint32 {
	return djb2.Combine(
		djb2.HashInt(b.targetId),
		djb2.HashInt(b.lifetime),
		djb2.HashInt(b.damage),
		djb2.HashInt(int(b.damageType)),
		djb2.HashInt(b.slowDuration),
		djb2.HashString(string(b.targetTeam)),
		b.damageRadius.Hash(),
		b.lastTargetPosition.Hash(),
	)
}

func (b *bullet) Update() {
	target := b.game.FindUnit(b.targetId)
	if target != nil {
		b.lastTargetPosition = target.Position()
	}
	if b.lifetime <= 0 {
		if b.damageRadius == 0 { // normal
			if target != nil {
				target.TakeDamage(b.damage, b.damageType)
				target.MakeSlow(b.slowDuration)
			}
		} else { // splash
			for _, id := range b.game.UnitIds() {
				u := b.game.FindUnit(id)
				if u.Team() != b.targetTeam {
					continue
				}
				d := b.lastTargetPosition.Sub(u.Position()).LengthSquared()
				r := u.Radius().Add(b.damageRadius)
				if d < r.Mul(r) {
					u.TakeDamage(b.damage, b.damageType)
					u.MakeSlow(b.slowDuration)
				}
			}
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

func (b *bullet) MakeSplash(radius fixed.Scalar) {
	target := b.game.FindUnit(b.targetId)
	b.targetTeam = target.Team()
	b.damageRadius = radius
}
