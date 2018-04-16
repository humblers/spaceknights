package main

type InstructManager struct {
	Player *Player
}

func NewInstructManager() *InstructManager {
	return &InstructManager{}
}

func (i *InstructManager) SetPlayer(player *Player) {
	i.Player = player
}

func (i *InstructManager) BuildDeck() Cards {
	unitCards := make(Cards, 0, len(CostMap))
	for name, _ := range CostMap {
		if name == "fireball" || name == "laser" || name == "freeze" {
			continue
		}
		unitCards = append(unitCards, name)
	}

	unitCards.Shuffle()
	return unitCards[:HandSize]
}

func (i *InstructManager) Update(game *Game) {
	// can't use card. do nothing.
	if i.Player.Energy < 1000 {
		return
	}

	// get closest thing and determine it's value
	pos := Vector2{0, 0}
	cost := 0
	for _, card := range game.WaitingCards {
		if card.Team == i.Player.Team {
			continue
		}
		pos, cost = i.Determine(card.Team, string(card.Name), card.Position, pos, cost)
	}
	for _, unit := range game.Units {
		if unit.Team == i.Player.Team {
			continue
		}
		if unit.Type != Troop {
			continue
		}
		pos, cost = i.Determine(unit.Team, unit.Name, unit.Position, pos, cost)
	}

	// pick card and make input based from cost
	for index, card := range i.Player.Hand {
		if cost < 1000 {
			return
		}
		if CostMap[card] > i.Player.Energy {
			continue
		}
		cost -= CostMap[card]
		i.Player.UseCard(Input{
			Use:      index + 1,
			Position: pos,
		}, game)
	}
}

func (i *InstructManager) Determine(team Team, name string, pos Vector2, prevPos Vector2, prevCost int) (Vector2, int) {
	if team == Home {
		pos = Vector2{MapWidth, MapHeight}.Minus(pos)
	}
	if pos.Y <= prevPos.Y {
		return prevPos, prevCost
	}
	if cost, exist := CostMap[Card(name)]; exist {
		return pos, cost
	}
	return pos, 1000
}
