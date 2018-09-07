package game

type barrack struct {
	*unit
	Decayable
	TileOccupier
	spawn  int
	player Player
}

func newBarrack(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "barrack", p.Team(), level, posX, posY, g)
	b := &barrack{
		unit:         u,
		TileOccupier: newTileOccupier(g),
		player:       p,
	}
	b.Decayable = newDecayable(b)
	return b
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
	if b.spawn%b.spawnInterval() == 0 {
		b.doSpawn()
	}
	b.spawn++
}

func (b *barrack) spawnInterval() int {
	return units[b.name]["spawninterval"].(int)
}

func (b *barrack) doSpawn() {
	card := units[b.name]
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
