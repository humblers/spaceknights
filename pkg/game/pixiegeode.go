package game

type pixiegeode struct {
	*unit
	Decayable
	TileOccupier
	spawn  int
	player Player
}

func newPixiegeode(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "pixiegeode", p.Team(), level, posX, posY, g)
	pg := &pixiegeode{
		unit:         u,
		TileOccupier: newTileOccupier(g),
		player:       p,
	}
	pg.Decayable = newDecayable(pg)
	return pg
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
	return units[pg.name]["spawninterval"].(int)
}

func (pg *pixiegeode) doSpawn() {
	card := units[pg.name]
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
