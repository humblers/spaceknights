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

func (m *micromissile) Update() {
	m.unit.Update()
	if m.freeze > 0 {
		m.attack = 0
		m.targetId = 0
		m.freeze--
		return
	}
	if m.attack > 0 {
		m.handleAttack()
	} else {
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

func (m *micromissile) handleAttack() {
	for _, id := range m.game.UnitIds() {
		u := m.game.FindUnit(id)
		if u.Team() == m.Team() {
			continue
		}
		d := m.Position().Sub(u.Position()).LengthSquared()
		r := m.Radius().Add(u.Radius()).Add(m.destroyRadius())
		if d < r.Mul(r) {
			u.TakeDamage(m.destroyDamage(), m)
		}
	}
	m.hp = 0
}

func (m *micromissile) destroyDamage() int {
	return data.Units[m.name]["destroydamage"].([]int)[m.level]
}

func (m *micromissile) destroyRadius() fixed.Scalar {
	r := data.Units[m.name]["destroyradius"].(int)
	return m.game.World().FromPixel(r)
}
