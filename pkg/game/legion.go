package game

import "github.com/humblers/spaceknights/pkg/fixed"

type legion struct {
	*unit
	player          Player
	targetId        int
	attack          int
	transform       int
	initPos         fixed.Vector
	castPos         fixed.Vector
	isCasting       bool
	movingToCastPos bool
}

func newLegion(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "legion", p.Team(), level, posX, posY, g)
	return &legion{
		unit:    u,
		player:  p,
		initPos: u.Position(),
	}
}

func (l *legion) TakeDamage(amount int) {
	l.unit.TakeDamage(amount)
	if l.IsDead() {
		l.player.OnKnightDead(l)
	}
}

func (l *legion) Update() {
	if l.isCasting {
		if l.movingToCastPos {
			if l.transform >= l.transformDelay() {
				if l.Position() == l.castPos {
					l.cast()
					l.movingToCastPos = false
				} else {
					v := l.castPos.Sub(l.Position())
					s := l.game.World().Dt().Mul(l.speed())
					len := v.LengthSquared()
					if len < s.Mul(s) {
						l.SetVelocity(fixed.Vector{0, 0})
						l.SetPosition(l.castPos)
					} else {
						len = len.Sqrt()
						l.SetVelocity(v.Mul(l.speed().Div(len)))
					}
				}
			} else {
				l.transform++
			}
		} else {
			if l.Position() == l.initPos {
				if l.transform > 0 {
					l.transform--
				} else {
					l.isCasting = false
					l.SetCollidable(true)
				}
			} else {
				v := l.initPos.Sub(l.Position())
				s := l.game.World().Dt().Mul(l.speed())
				len := v.LengthSquared()
				if len < s.Mul(s) {
					l.SetVelocity(fixed.Vector{0, 0})
					l.SetPosition(l.initPos)
				} else {
					len = len.Sqrt()
					l.SetVelocity(v.Mul(l.speed().Div(len)))
				}
			}
		}
	} else {
		if l.attack > 0 {
			l.handleAttack()
		} else {
			t := l.target()
			if t == nil {
				l.findTargetAndAttack()
			} else {
				if l.withinRange(t) {
					l.handleAttack()
				} else {
					l.findTargetAndAttack()
				}
			}
		}
	}
}

func (l *legion) findTargetAndAttack() {
	t := l.findTarget()
	l.setTarget(t)
	if t != nil && l.withinRange(t) {
		l.handleAttack()
	}
}

func (l *legion) CastSkill(posX, posY int) bool {
	if l.isCasting {
		return false
	}
	l.attack = 0
	l.isCasting = true
	l.movingToCastPos = true
	l.castPos = fixed.Vector{
		l.game.World().FromPixel(posX),
		l.game.World().FromPixel(posY),
	}
	l.SetCollidable(false)
	return true
}

func (l *legion) cast() {
	damage := cards[l.Skill()]["damage"].([]int)[l.level]
	radius := l.game.World().FromPixel(cards[l.Skill()]["radius"].(int))
	for _, id := range l.game.UnitIds() {
		u := l.game.FindUnit(id)
		if u.Team() == l.Team() {
			continue
		}
		d := l.squaredDistanceTo(u)
		r := u.Radius().Add(radius)
		if d < r.Mul(r) {
			u.TakeDamage(damage)
		}
	}
}

func (l *legion) target() Unit {
	return l.game.FindUnit(l.targetId)
}

func (l *legion) setTarget(u Unit) {
	if u == nil {
		l.targetId = 0
	} else {
		l.targetId = u.Id()
	}
}

func (l *legion) handleAttack() {
	if l.attack == l.preAttackDelay() {
		t := l.target()
		if t != nil && l.withinRange(t) {
			l.fire()
		} else {
			l.attack = 0
			return
		}
	}
	l.attack++
	if l.attack > l.attackInterval() {
		l.attack = 0
	}
}

func (l *legion) fire() {
	b := newBullet(l.targetId, l.bulletLifeTime(), l.attackDamage())
	l.game.AddBullet(b)
}
