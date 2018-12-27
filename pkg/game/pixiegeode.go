package game

import "github.com/humblers/spaceknights/pkg/data"

type pixiegeode struct {
	*unit
	Decayable
	spawn  int
	player Player
}

func newPixiegeode(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "pixiegeode", p.Team(), level, posX, posY, g)
	pg := &pixiegeode{
		unit:   u,
		player: p,
	}
	pg.Decayable = newDecayable(pg)
	return pg
}

func (pg *pixiegeode) TakeDamage(amount int, damageType data.DamageType) {
	if damageType == data.Skill || damageType == data.Death {
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	}
	pg.unit.TakeDamage(amount, damageType)
}

func (pg *pixiegeode) Destroy() {
	pg.unit.Destroy()
	pg.Release()
}

func (pg *pixiegeode) Update() {
	pg.TakeDecayDamage()
	if pg.freeze > 0 {
		pg.freeze--
		return
	}
	if pg.spawn%pg.spawnInterval() == 5 {
		pg.doSpawn()
	}
	pg.spawn++
}

func (pg *pixiegeode) spawnInterval() int {
	return data.Units[pg.name]["spawninterval"].(int)
}

func (pg *pixiegeode) doSpawn() {
	card := data.Units[pg.name]
	name := card["spawn"].(string)
	count := card["spawncount"].(int)
	offsetX := card["spawnoffsetX"].([]int)
	offsetY := card["spawnoffsetY"].([]int)
	posX := pg.game.World().ToPixel(pg.Position().X)
	posY := pg.game.World().ToPixel(pg.Position().Y)
	for i := 0; i < count; i++ {
		pg.game.AddUnit(name, pg.level, posX+offsetX[i], posY+offsetY[i], pg.player)
	}
}
