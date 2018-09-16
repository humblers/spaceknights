package game

import "github.com/humblers/spaceknights/pkg/fixed"

type ironcoffin struct {
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
	castTile TileOccupier
}

func newIroncoffin(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "ironcoffin", p.Team(), level, posX, posY, g)
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
	return &ironcoffin{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		minPosX:      u.Position().X.Sub(offsetX),
		maxPosX:      u.Position().X.Add(offsetX),
		castTile:     newTileOccupier(g),
	}
}

func (i *ironcoffin) TakeDamage(amount int, t AttackType) {
	i.unit.TakeDamage(amount, t)
	if i.IsDead() {
		i.player.OnKnightDead(i)
	}
}

func (i *ironcoffin) Destroy() {
	i.unit.Destroy()
	i.TileOccupier.Release()
	i.castTile.Release()
}

func (i *ironcoffin) attackDamage() int {
	damage := i.unit.attackDamage()
	divider := 1
	for _, ratio := range i.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (i *ironcoffin) attackRange() fixed.Scalar {
	atkRange := units[i.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range i.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return i.game.World().FromPixel(atkRange / divider)
}

func (i *ironcoffin) Update() {
	if i.isLeader {
		data := passives[i.Skill()]
		if i.game.Step()%data["perstep"].(int) == 0 {
			i.spawn(data)
		}
	}
	if i.freeze > 0 {
		i.attack = 0
		i.targetId = 0
		i.freeze--
		return
	}
	if i.cast > 0 {
		if i.cast == i.preCastDelay()+1 {
			i.spawn(cards[i.Skill()])
		}
		if i.cast > i.castDuration() {
			i.cast = 0
			i.setLayer(i.initialLayer())
		} else {
			i.cast++
		}
	} else {
		if i.target() == nil {
			i.setTarget(i.findTarget())
			i.attack = 0
		}
		t := i.target()
		if t != nil && i.canSee(t) {
			posX := t.Position().X
			if posX < i.minPosX {
				posX = i.minPosX
			} else if posX > i.maxPosX {
				posX = i.maxPosX
			}
			i.moveTo(fixed.Vector{posX, i.Position().Y})
			if i.withinRange(t) {
				if i.attack%i.attackInterval() == 0 {
					t.TakeDamage(i.attackDamage(), Range)
					duration := 0
					for _, d := range i.player.StatRatios("slowduration") {
						duration += d
					}
					t.MakeSlow(duration)
				}
				i.attack++
			} else {
				i.attack = 0
			}
		} else {
			i.moveTo(i.initPos)
			i.attack = 0
		}
	}
}

func (i *ironcoffin) castDuration() int {
	return cards[i.Skill()]["castduration"].(int)
}

func (i *ironcoffin) preCastDelay() int {
	return cards[i.Skill()]["precastdelay"].(int)
}

func (i *ironcoffin) SetAsLeader() {
	i.isLeader = true
}

func (i *ironcoffin) Skill() string {
	key := "active"
	if i.isLeader {
		key = "passive"
	}
	return units[i.name][key].(string)
}

func (i *ironcoffin) CastSkill(posX, posY int) bool {
	if i.cast > 0 {
		return false
	}

	name := cards[i.Skill()]["unit"].(string)
	nx := units[name]["tilenumx"].(int)
	ny := units[name]["tilenumy"].(int)
	tx, ty := i.game.TileFromPos(posX, posY)
	tr := i.castTile.GetRect(tx, ty, nx, ny)
	if err := i.castTile.Occupy(tr); err != nil {
		i.game.Logger().Print(err)
		return false
	}

	i.attack = 0
	i.cast++
	i.castPosX = posX
	i.castPosY = posY
	i.setLayer(Casting)
	return true
}

func (i *ironcoffin) spawn(data map[string]interface{}) {
	name := data["unit"].(string)
	if name == "sentryshelter" {
		id := i.game.AddUnit(name, i.level, i.castPosX, i.castPosY, i.player)
		tr := i.castTile.Occupied()
		i.castTile.Release()
		if occupier, ok := i.game.FindUnit(id).(TileOccupier); ok {
			if err := occupier.Occupy(tr); err != nil {
				panic(err)
			}
		}
	}
	if name == "sentry" {
		posX := i.game.World().ToPixel(i.initPos.X)
		posY := i.game.World().ToPixel(i.initPos.Y)
		i.game.AddUnit(name, i.level, posX, posY, i.player)
	}
}

func (i *ironcoffin) target() Unit {
	return i.game.FindUnit(i.targetId)
}

func (i *ironcoffin) setTarget(u Unit) {
	if u == nil {
		i.targetId = 0
	} else {
		i.targetId = u.Id()
	}
}
