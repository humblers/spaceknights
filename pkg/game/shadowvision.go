package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type shadowvision struct {
	*unit
	targetId int
	attack   int
	shield   int
}

func newShadowvision(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "shadowvision", p.Team(), level, posX, posY, g)
	return &shadowvision{
		unit:   u,
		shield: u.initialShield(),
	}
}

func (s *shadowvision) TakeDamage(amount int, t AttackType) {
	if s.Layer() != data.Normal {
		return
	}
	if t != Melee {
		s.shield -= amount
		if s.shield < 0 {
			s.hp += s.shield
			s.shield = 0
		}
	} else {
		s.hp -= amount
	}
}

func (s *shadowvision) Update() {
	s.SetVelocity(fixed.Vector{0, 0})
	if s.freeze > 0 {
		s.attack = 0
		s.targetId = 0
		s.freeze--
		return
	}
	if s.attack > 0 {
		s.handleAttack()
	} else {
		t := s.target()
		if t == nil {
			s.findTargetAndDoAction()
		} else {
			if s.withinRange(t) {
				s.handleAttack()
			} else {
				s.findTargetAndDoAction()
			}
		}
	}
	s.shield += ShieldRegenPerStep
	if s.shield > s.initialShield() {
		s.shield = s.initialShield()
	}
}

func (s *shadowvision) target() Unit {
	return s.game.FindUnit(s.targetId)
}

func (s *shadowvision) setTarget(u Unit) {
	if u == nil {
		s.targetId = 0
	} else {
		s.targetId = u.Id()
	}
}

func (s *shadowvision) fire() {
	b := newBullet(s.targetId, s.bulletLifeTime(), s.attackDamage(), s.game)
	s.game.AddBullet(b)
}

func (s *shadowvision) findTargetAndDoAction() {
	t := s.findTarget()
	s.setTarget(t)
	if t != nil {
		if s.withinRange(t) {
			s.handleAttack()
		} else {
			s.moveTo(t)
		}
	}
}

func (s *shadowvision) moveTo(u Unit) {
	direction := u.Position().Sub(s.Position()).Normalized()
	s.SetVelocity(direction.Mul(s.speed()))
}

func (s *shadowvision) handleAttack() {
	if s.attack == 0 {
		s.setLayer(data.Normal)
	}
	if s.attack == s.preAttackDelay() {
		t := s.target()
		if t != nil && s.withinRange(t) {
			s.fire()
		} else {
			s.attack = 0
			s.setLayer(s.initialLayer())
			return
		}
	}
	s.attack++
	if s.attack > s.attackInterval() {
		s.attack = 0
		s.setLayer(s.initialLayer())
	}
}
