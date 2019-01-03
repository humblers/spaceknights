package game

import "github.com/humblers/spaceknights/pkg/data"

type barrack struct {
	*unit
	Decayable
	spawn  int
	player Player
}

func newBarrack(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "barrack", p.Team(), level, posX, posY, g)
	b := &barrack{
		unit:   u,
		player: p,
	}
	b.Decayable = newDecayable(b)
	return b
}

func (b *barrack) TakeDamage(amount int, damageType data.DamageType) {
	if damageType == data.Skill || damageType == data.Death {
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	}
	b.unit.TakeDamage(amount, damageType)
}

func (b *barrack) Destroy() {
	b.unit.Destroy()
	b.Release()
}

func (b *barrack) Update() {
	b.TakeDecayDamage()
	if b.freeze > 0 {
		b.freeze--
		return
	}
	if b.spawn%b.spawnInterval() == 15 {
		b.doSpawn()
	}
	b.spawn++
}

func (b *barrack) spawnInterval() int {
	return data.Units[b.name]["spawninterval"].(int)
}

func (b *barrack) doSpawn() {
	card := data.Units[b.name]
	name := card["spawn"].(string)
	count := card["spawncount"].(int)
	offsetX := card["spawnoffsetX"].([]int)
	offsetY := card["spawnoffsetY"].([]int)
	posX := b.game.World().ToPixel(b.Position().X)
	posY := b.game.World().ToPixel(b.Position().Y)
	for i := 0; i < count; i++ {
		b.game.AddUnit(name, b.level, posX+offsetX[i], posY+offsetY[i], b.player)
	}
}
