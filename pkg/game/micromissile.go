package game

import "github.com/humblers/spaceknights/pkg/data"
import "github.com/humblers/spaceknights/pkg/fixed"

type micromissile struct {
	*unit
	targetId int
	attack   int // elapsed time since attack start
}

func newMicromissile(id int, level, posX, posY int, g Game, p Player) Unit {
	return &micromissile{
		unit: newUnit(id, "micromissile", p.Team(), level, posX, posY, g),
	}
}

func (m *micromissile) TakeDamage(amount int, damageType data.DamageType) {
	alreadyDead := m.IsDead()
	m.unit.TakeDamage(amount, damageType)
	if !alreadyDead && m.IsDead() && m.attack > 0 && m.attack <= m.preAttackDelay() {
		m.suicideAttack()
		m.attack = m.preAttackDelay() + 1
	}
}

func (m *micromissile) Update() {
	m.unit.Update()
	if m.attack > 0 {
		m.handleAttack()
	} else {
		if m.freeze > 0 {
			m.targetId = 0
			m.freeze--
			return
		}
		t := m.target()
		if t == nil {
			m.findTargetAndDoAction()
		} else {
			if m.withinRange(t) {
				m.handleAttack()
			} else {
				m.findTargetAndDoAction()
			}
		}
	}
}

func (m *micromissile) target() Unit {
	return m.game.FindUnit(m.targetId)
}

func (m *micromissile) setTarget(u Unit) {
	if u == nil {
		m.targetId = 0
	} else {
		m.targetId = u.Id()
	}
}

func (m *micromissile) findTargetAndDoAction() {
	t := m.findTarget()
	m.setTarget(t)
	if t != nil {
		if m.withinRange(t) {
			m.handleAttack()
		} else {
			m.moveTo(t)
		}
	}
}

func (m *micromissile) suicideAttack() {
	for _, id := range m.game.UnitIds() {
		u := m.game.FindUnit(id)
		if u.Team() == m.Team() {
			continue
		}
		d := m.Position().Sub(u.Position()).LengthSquared()
		r := u.Radius().Add(m.attackRadius())
		if d < r.Mul(r) {
			u.TakeDamage(m.attackDamage(), m.damageType())
		}
	}
	if !m.IsDead() {
		m.hp = 0
	}
}

func (m *micromissile) handleAttack() {
	if m.attack == m.preAttackDelay() {
		m.suicideAttack()
	}
	m.attack++
}

func (m *micromissile) attackRadius() fixed.Scalar {
	r := data.Units[m.name]["attackradius"].(int)
	return m.game.World().FromPixel(r)
}
