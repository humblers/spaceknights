package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type astra struct {
	*unit
	TileOccupier
	player   Player
	isLeader bool
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
	minPosX  fixed.Scalar
	maxPosX  fixed.Scalar
	castPosX int
	castPosY int
}

func newAstra(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "astra", p.Team(), level, posX, posY, g)
	to := newTileOccupier(g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{t: ty - 2, b: ty + 1, l: tx - 2, r: tx + 1}
	if err := to.Occupy(tr); err != nil {
		panic(err)
	}
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &astra{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		minPosX:      u.Position().X.Sub(offsetX),
		maxPosX:      u.Position().X.Add(offsetX),
	}
}

func (a *astra) TakeDamage(amount int, atk Attacker) {
	a.unit.TakeDamage(amount, atk)
	if a.IsDead() {
		a.player.OnKnightDead(a)
	}
}

func (a *astra) Destroy() {
	a.unit.Destroy()
	a.Release()
}

func (a *astra) DamageType() data.DamageType {
	if a.cast > 0 {
		return a.Skill()["damagetype"].(data.DamageType)
	}
	return a.unit.DamageType()
}

func (a *astra) attackDamage() int {
	damage := a.unit.attackDamage()
	divider := 1
	for _, ratio := range a.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (a *astra) attackRange() fixed.Scalar {
	atkRange := data.Units[a.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range a.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return a.game.World().FromPixel(atkRange / divider)
}

func (a *astra) Update() {
	if a.freeze > 0 {
		a.attack = 0
		a.targetId = 0
		a.freeze--
		return
	}
	if a.cast > 0 {
		if a.cast > a.laserStart() && a.cast <= a.laserEnd() {
			a.deal()
		}
		if a.cast > a.laserDuration() {
			a.cast = 0
			a.setLayer(a.initialLayer())
		} else {
			a.cast++
		}
	} else {
		if a.target() == nil {
			a.setTarget(a.findTarget())
			a.attack = 0
		}
		t := a.target()
		if t != nil && a.canSee(t) {
			posX := t.Position().X
			if posX < a.minPosX {
				posX = a.minPosX
			} else if posX > a.maxPosX {
				posX = a.maxPosX
			}
			a.moveToPos(fixed.Vector{posX, a.Position().Y})
			if a.withinRange(t) {
				if a.attack%a.attackInterval() == 0 {
					t.TakeDamage(a.attackDamage(), a)
					duration := 0
					for _, d := range a.player.StatRatios("slowduration") {
						duration += d
					}
					t.MakeSlow(duration)
				}
				a.attack++
			} else {
				a.attack = 0
			}
		} else {
			a.moveToPos(a.initPos)
			a.attack = 0
		}
	}
}

func (a *astra) deal() {
	for _, id := range a.game.UnitIds() {
		u := a.game.FindUnit(id)
		if u.Team() == a.Team() {
			continue
		}
		if a.inLaserArea(u) {
			u.TakeDamage(a.laserDamage(), a)
		}
	}
}

func (a *astra) laserDuration() int {
	return a.Skill()["duration"].(int)
}

func (a *astra) laserStart() int {
	return a.Skill()["start"].(int)
}

func (a *astra) laserEnd() int {
	return a.Skill()["end"].(int)
}

func (a *astra) laserDamage() int {
	switch v := a.Skill()["damage"].(type) {
	case int:
		return v
	case []int:
		return v[a.level]
	}
	panic("invalid laser damage type")
}

func (a *astra) laserWidth() fixed.Scalar {
	return a.game.World().FromPixel(a.Skill()["width"].(int))
}

func (a *astra) laserHeight() fixed.Scalar {
	return a.game.World().FromPixel(a.Skill()["height"].(int))
}

func (a *astra) inLaserArea(u Unit) bool {
	var y fixed.Scalar
	if a.Team() == Blue {
		y = a.game.World().FromPixel(a.castPosY).Sub(a.laserHeight())
	} else {
		y = a.game.World().FromPixel(a.castPosY).Add(a.laserHeight())
	}
	center := fixed.Vector{a.game.World().FromPixel(a.castPosX), y}
	return boxVSCircle(center, u.Position(), a.laserWidth(), a.laserHeight(), u.Radius())
}

func (a *astra) SetAsLeader() {
	a.isLeader = true
	a.player.AddStatRatio("hpratio", a.Skill()["hpratio"].([]int)[a.level])
}

func (a *astra) Skill() map[string]interface{} {
	skill := data.Units[a.name]["skill"].(map[string]interface{})
	key := "wing"
	if a.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (a *astra) CastSkill(posX, posY int) bool {
	if a.cast > 0 {
		return false
	}
	a.attack = 0
	a.cast++
	a.castPosX = posX
	a.castPosY = posY
	a.setLayer(data.Casting)
	return true
}

func (a *astra) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *astra) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}
