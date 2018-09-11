package game

import "github.com/humblers/spaceknights/pkg/fixed"

type ISkill interface {
	Update()
	IsExpired() bool
}

type DOT struct {
	team          Team
	position      fixed.Vector
	width         fixed.Scalar
	height        fixed.Scalar
	damagePerSec  int
	remainingStep int
	game          Game
}

func newDOT(t Team, p fixed.Vector, w, h fixed.Scalar, dps, remain int, g Game) ISkill {
	return &DOT{
		team:          t,
		position:      p,
		width:         w,
		height:        h,
		damagePerSec:  dps,
		remainingStep: remain,
		game:          g,
	}
}

func (dot *DOT) Update() {
	if dot.remainingStep%stepPerSec == 0 {
		for _, id := range dot.game.UnitIds() {
			u := dot.game.FindUnit(id)
			if u.Team() == dot.team {
				continue
			}
			if dot.InArea(u) {
				u.TakeDamage(dot.damagePerSec, Skill)
			}
		}
	}
	dot.remainingStep--
}

func (dot *DOT) IsExpired() bool {
	return dot.remainingStep <= 0
}

func (dot *DOT) InArea(u Unit) bool {
	return boxVSCircle(dot.position, u.Position(), dot.width, dot.height, u.Radius())
}
