package game

type starfire struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newStarfire(id int, level, posX, posY int, g Game, p Player) Unit {
	return &starfire{
		unit: newUnit(id, "starfire", p.Team(), level, posX, posY, g),
	}
}

func (s *starfire) Update() {
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

func (s *starfire) target() Unit {
	return s.game.FindUnit(s.targetId)
}

func (s *starfire) setTarget(u Unit) {
	if u == nil {
		s.targetId = 0
	} else {
		s.targetId = u.Id()
	}
}

func (s *starfire) fire() {
	b := newBullet(s.targetId, s.bulletLifeTime(), s.attackDamage(), s.DamageType(), s.game)
	s.game.AddBullet(b)
}

func (s *starfire) findTargetAndDoAction() {
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

func (s *starfire) handleAttack() {
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
