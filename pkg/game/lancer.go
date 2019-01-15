package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type lancer struct {
	*unit
	player      Player
	isLeader    bool
	targetId    int
	attack      int
	cast        int
	initPos     fixed.Vector
	minPosX     fixed.Scalar
	maxPosX     fixed.Scalar
	castPosX    int
	castPosY    int
	retargeting bool
}

func newLancer(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "lancer", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &lancer{
		unit:    u,
		player:  p,
		initPos: u.Position(),
		minPosX: u.Position().X.Sub(offsetX),
		maxPosX: u.Position().X.Add(offsetX),
	}
}

func (l *lancer) TakeDamage(amount int, damageType data.DamageType) {
	if damageType.Is(data.DecreaseOnKnight) {
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	}
	l.unit.TakeDamage(amount, damageType)
	if l.IsDead() {
		l.player.OnKnightDead(l)
	}
}

func (l *lancer) Destroy() {
	l.unit.Destroy()
	l.Release()
}

func (l *lancer) attackDamage() int {
	damage := l.unit.attackDamage()
	divider := 1
	for _, ratio := range l.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	damage /= divider
	limits := l.player.StatRatios("amplifycountlimit")
	for i, amplify := range l.player.StatRatios("amplifydamagepersec") {
		cnt := l.attack / data.StepPerSec
		if cnt > limits[i] {
			cnt = limits[i]
		}
		damage += amplify * cnt * l.attackInterval() / data.StepPerSec
	}
	return damage
}

func (l *lancer) attackRange() fixed.Scalar {
	atkRange := data.Units[l.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range l.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return l.game.World().FromPixel(atkRange / divider)
}

func (l *lancer) Update() {
	if l.freeze > 0 {
		l.attack = 0
		l.targetId = 0
		l.freeze--
		return
	}
	if l.cast > 0 {
		if l.cast == l.preCastDelay()+1 {
			l.drop()
		}
		if l.cast > l.castDuration() {
			l.cast = 0
			l.setLayer(l.initialLayer())
		} else {
			l.cast++
		}
	} else {
		if l.attack > 0 && l.retargeting {
			l.handleAttack()
		} else {
			t := l.target()
			if t == nil {
				l.attack = 0
				l.findTargetAndDoAction()
			} else {
				if l.withinRange(t) {
					l.handleAttack()
				} else {
					l.attack = 0
					l.findTargetAndDoAction()
				}
			}
		}
	}
}

func (l *lancer) findTargetAndDoAction() {
	t := l.findTarget()
	l.setTarget(t)
	if t != nil {
		if l.withinRange(t) {
			l.handleAttack()
		} else {
			l.moveToPos(
				fixed.Vector{
					t.Position().X.Clamp(l.minPosX, l.maxPosX),
					l.Position().Y,
				},
			)
		}
	} else {
		l.moveToPos(l.initPos) // back to init pos
	}
}

func (l *lancer) castDuration() int {
	return l.Skill()["castduration"].(int)
}

func (l *lancer) preCastDelay() int {
	return l.Skill()["precastdelay"].(int)
}

func (l *lancer) SetAsLeader() {
	l.isLeader = true

	s := l.Skill()
	count := s["count"].(int)
	posX := s["posX"].([]int)
	posY := s["posY"].([]int)
	w := l.game.World().FromPixel(s["width"].(int))
	h := l.game.World().FromPixel(s["height"].(int))
	damage := s["damage"].(int)
	damageType := s["damagetype"].(data.DamageType)
	duration := s["duration"].(int)
	for i := 0; i < count; i++ {
		pos := fixed.Vector{
			l.game.World().FromPixel(posX[i]),
			l.game.World().FromPixel(posY[i]),
		}
		dot := newDOT(l.team, pos, w, h, damage, duration, damageType, l.game)
		l.game.AddSkill(dot)
	}
}

func (l *lancer) Skill() map[string]interface{} {
	skill := data.Units[l.name]["skill"].(map[string]interface{})
	key := "wing"
	if l.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (l *lancer) CanCastSkill() bool {
	return l.cast <= 0
}

func (l *lancer) CastSkill(posX, posY int) {
	l.attack = 0
	l.cast++
	l.castPosX = posX
	l.castPosY = posY
	l.setLayer(data.Casting)
}

func (l *lancer) drop() {
	dps := l.Skill()["damage"].(int)
	w := l.game.World().FromPixel(l.Skill()["width"].(int))
	h := l.game.World().FromPixel(l.Skill()["height"].(int))
	remain := l.Skill()["damageduration"].(int)
	pos := fixed.Vector{
		l.game.World().FromPixel(l.castPosX),
		l.game.World().FromPixel(l.castPosY),
	}
	damageType := l.Skill()["damagetype"].(data.DamageType)
	dot := newDOT(l.team, pos, w, h, dps, remain, damageType, l.game)
	l.game.AddSkill(dot)
}

func (l *lancer) target() Unit {
	return l.game.FindUnit(l.targetId)
}

func (l *lancer) setTarget(u Unit) {
	if u == nil {
		l.targetId = 0
	} else {
		l.targetId = u.Id()
	}
}

func (l *lancer) handleAttack() {
	modulo := l.attack % l.attackInterval()
	if modulo == l.preAttackDelay() {
		t := l.target()
		if t != nil && l.withinRange(t) {
			l.fire()
		} else {
			l.retargeting = true
			return
		}
	}
	l.retargeting = l.attack > 0 && modulo == 0
	l.attack++
}

func (l *lancer) fire() {
	b := newBullet(l.targetId, l.bulletLifeTime(), l.attackDamage(), l.damageType(), l.game)
	duration := 0
	for _, d := range l.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	var damageRadius fixed.Scalar = 0
	for _, r := range l.player.StatRatios("expanddamageradius") {
		damageRadius = damageRadius.Add(l.game.World().FromPixel(r))
	}
	b.MakeSplash(damageRadius)
	l.game.AddBullet(b)
}
