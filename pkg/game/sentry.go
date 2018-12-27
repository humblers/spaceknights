package game

type sentry struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newSentry(id int, level, posX, posY int, g Game, p Player) Unit {
	return &sentry{
		unit: newUnit(id, "sentry", p.Team(), level, posX, posY, g),
	}
}

func (s *sentry) Update() {
	s.unit.Update()
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
}

func (s *sentry) target() Unit {
	return s.game.FindUnit(s.targetId)
}

func (s *sentry) setTarget(u Unit) {
	if u == nil {
		s.targetId = 0
	} else {
		s.targetId = u.Id()
	}
}

func (s *sentry) fire() {
	b := newBullet(s.targetId, s.bulletLifeTime(), s.attackDamage(), s.damageType(), s.game)
	s.game.AddBullet(b)
}

func (s *sentry) findTargetAndDoAction() {
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

func (s *sentry) handleAttack() {
	if s.attack == s.preAttackDelay() {
		t := s.target()
		if t != nil && s.withinRange(t) {
			s.fire()
		} else {
			s.attack = 0
			return
		}
	}
	s.attack++
	if s.attack > s.attackInterval() {
		s.attack = 0
	}
}
