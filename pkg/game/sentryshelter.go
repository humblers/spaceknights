package game

type sentryshelter struct {
	*unit
	Decayable
	TileOccupier
	spawn  int
	player Player
}

func newSentryshelter(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "sentryshelter", p.Team(), level, posX, posY, g)
	s := &sentryshelter{
		unit:         u,
		TileOccupier: newTileOccupier(g),
		player:       p,
	}
	s.Decayable = newDecayable(s)
	return s
}

func (s *sentryshelter) Destroy() {
	s.unit.Destroy()
	s.Release()
}

func (s *sentryshelter) Update() {
	s.TakeDecayDamage()
	if s.freeze > 0 {
		s.freeze--
		return
	}
	if s.spawn%s.spawnInterval() == 10 {
		s.doSpawn()
	}
	s.spawn++
}

func (s *sentryshelter) spawnInterval() int {
	return units[s.name]["spawninterval"].(int)
}

func (s *sentryshelter) doSpawn() {
	card := units[s.name]
	name := card["spawn"].(string)
	count := card["spawncount"].(int)
	offsetX := card["spawnoffsetX"].([]int)
	offsetY := card["spawnoffsetY"].([]int)
	posX := s.game.World().ToPixel(s.Position().X)
	posY := s.game.World().ToPixel(s.Position().Y)
	for i := 0; i < count; i++ {
		s.game.AddUnit(name, s.level, posX+offsetX[i], posY+offsetY[i], s.player)
	}
}
