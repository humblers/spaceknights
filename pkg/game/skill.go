package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/djb2"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type ISkill interface {
	Update()
	IsExpired() bool
	Hash() uint32
	State() map[string]interface{}
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

func (d *DOT) State() map[string]interface{} {
	return map[string]interface{}{
		"team":          d.team,
		"position":      d.position,
		"width":         d.width,
		"height":        d.height,
		"damagePerSec":  d.damagePerSec,
		"remainingStep": d.remainingStep,
		"damageType":    d.damageType,
	}
}

func (d *DOT) Hash() uint32 {
	return djb2.Combine(
		djb2.HashString(string(d.team)),
		d.position.Hash(),
		d.width.Hash(),
		d.height.Hash(),
		djb2.HashInt(d.damagePerSec),
		djb2.HashInt(d.remainingStep),
		djb2.HashInt(int(d.damageType)),
	)
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
