package game

import "github.com/humblers/spaceknights/pkg/fixed"

type lancer struct {
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

func newLancer(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "lancer", p.Team(), level, posX, posY, g)
	hp := u.hp
	divider := 1
	for _, ratio := range p.StatRatios("hpratio") {
		hp *= ratio
		divider *= 100
	}
	u.hp = hp / divider
	to := newTileOccupier(g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{t: ty - 2, b: ty + 1, l: tx - 2, r: tx + 1}
	if err := to.Occupy(tr); err != nil {
		panic(err)
	}
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &lancer{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		minPosX:      u.Position().X.Sub(offsetX),
		maxPosX:      u.Position().X.Add(offsetX),
	}
}

func (l *lancer) TakeDamage(amount int, t AttackType) {
	l.unit.TakeDamage(amount, t)
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
	return damage / divider
}

func (l *lancer) attackRange() fixed.Scalar {
	atkRange := units[l.name]["attackrange"].(int)
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
		if l.attack > 0 {
			l.handleAttack()
		} else {
			t := l.target()
			if t == nil {
				l.findTargetAndDoAction()
			} else {
				if l.withinRange(t) {
					l.handleAttack()
				} else {
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
	return cards[l.Skill()]["castduration"].(int)
}

func (l *lancer) preCastDelay() int {
	return cards[l.Skill()]["precastdelay"].(int)
}

func (l *lancer) SetAsLeader() {
	l.isLeader = true

	data := passives[l.Skill()]
	count := data["count"].(int)
	posX := data["posX"].([]int)
	posY := data["posY"].([]int)
	w := l.game.World().FromPixel(data["width"].(int))
	h := l.game.World().FromPixel(data["height"].(int))
	damage := data["damage"].(int)
	duration := data["duration"].(int)
	for i := 0; i < count; i++ {
		pos := fixed.Vector{
			l.game.World().FromPixel(posX[i]),
			l.game.World().FromPixel(posY[i]),
		}
		dot := newDOT(l.team, pos, w, h, damage, duration, l.game)
		l.game.AddSkill(dot)
	}
}

func (l *lancer) Skill() string {
	key := "active"
	if l.isLeader {
		key = "passive"
	}
	return units[l.name][key].(string)
}

func (l *lancer) CastSkill(posX, posY int) bool {
	if l.cast > 0 {
		return false
	}
	l.attack = 0
	l.cast++
	l.castPosX = posX
	l.castPosY = posY
	l.setLayer(Casting)
	return true
}

func (l *lancer) drop() {
	dps := cards[l.Skill()]["damage"].(int)
	w := l.game.World().FromPixel(cards[l.Skill()]["width"].(int))
	h := l.game.World().FromPixel(cards[l.Skill()]["height"].(int))
	remain := cards[l.Skill()]["damageduration"].(int)
	pos := fixed.Vector{
		l.game.World().FromPixel(l.castPosX),
		l.game.World().FromPixel(l.castPosY),
	}
	dot := newDOT(l.team, pos, w, h, dps, remain, l.game)
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
	if l.attack == l.preAttackDelay() {
		t := l.target()
		if t != nil && l.withinRange(t) {
			l.fire()
		} else {
			l.attack = 0
			return
		}
	}
	l.attack++
	if l.attack > l.attackInterval() {
		l.attack = 0
	}
}

func (l *lancer) fire() {
	b := newBullet(l.targetId, l.bulletLifeTime(), l.attackDamage(), l.game)
	duration := 0
	for _, d := range l.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	l.game.AddBullet(b)
}
