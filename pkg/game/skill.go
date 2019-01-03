package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

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
	damageType    data.DamageType
	game          Game
}

func newDOT(t Team, p fixed.Vector, w, h fixed.Scalar, dps, remain int, damageType data.DamageType, g Game) ISkill {
	return &DOT{
		team:          t,
		position:      p,
		width:         w,
		height:        h,
		damagePerSec:  dps,
		remainingStep: remain,
		damageType:    damageType,
		game:          g,
	}
}

func (dot *DOT) Update() {
	if dot.remainingStep%data.StepPerSec == 0 {
		for _, id := range dot.game.UnitIds() {
			u := dot.game.FindUnit(id)
			if u.Team() == dot.team {
				continue
			}
			if dot.InArea(u) {
				u.TakeDamage(dot.damagePerSec, dot.damageType)
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
