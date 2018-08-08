package game

import "github.com/humblers/spaceknights/pkg/fixed"

type shadowvision struct {
	*unit
	targetId int
	attack   int
	layer    Layer
}

func newShadowvision(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "shadowvision", p.Team(), level, posX, posY, g)
	return &shadowvision{
		unit:  u,
		layer: u.Layer(),
	}
}

func (s *shadowvision) Layer() Layer {
	return s.layer
}

func (s *shadowvision) Update() {
	s.SetVelocity(fixed.Vector{0, 0})
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
	b := newBullet(s.targetId, s.bulletLifeTime(), s.attackDamage())
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
	corner := s.game.Map().FindNextCornerInPath(
		s.Position(),
		u.Position(),
		s.Radius(),
	)
	direction := corner.Sub(s.Position()).Normalized()
	s.SetVelocity(direction.Mul(s.speed()))
}

func (s *shadowvision) handleAttack() {
	if s.attack == 0 {
		s.layer = Normal
	}
	if s.attack == s.preAttackDelay() {
		t := s.target()
		if t != nil && s.withinRange(t) {
			s.fire()
		} else {
			s.attack = 0
			s.layer = s.unit.Layer()
			return
		}
	}
	s.attack++
	if s.attack > s.attackInterval() {
		s.attack = 0
		s.layer = s.unit.Layer()
	}
}
