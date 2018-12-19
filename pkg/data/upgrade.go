package data

import (
	"encoding/json"
	"fmt"
)

type upgrade struct {
	RelativeLvByRarity map[CardRarity]int
	CardCost           []int
	CoinCost           []int
}

var Upgrade = upgrade{
	RelativeLvByRarity: map[CardRarity]int{
		Common:    0,
		Rare:      2,
		Epic:      5,
		Legendary: 8,
	},

	CardCost: []int{
		2,
		4,
		10,
		20,
		50,
		100,
		200,
		400,
		800,
		1000,
		2000,
		5000,
	},
	CoinCost: []int{
		5,
		20,
		50,
		150,
		400,
		1000,
		2000,
		4000,
		8000,
		20000,
		50000,
		100000,
	},
}

var upgrade_str string

func (u upgrade) String() string {
	if upgrade_str == "" {
		b, err := json.Marshal(u)
		if err != nil {
			panic(fmt.Errorf("can't marshaling upgrade data: %v", err))
		}
		upgrade_str = string(b)
	}
	return upgrade_str
}

func (u upgrade) CardCostNextLevel(level int) int {
	return u.CardCost[level]
}

func (u upgrade) CardCostToLevel(from, to int) int {
	cost := 0
	for i := from; i < to; i++ {
		cost += u.CardCost[i]
	}
	return cost
}

func (u upgrade) CoinCostNextLevel(rarity CardRarity, level int) int {
	relLv := u.RelativeLvByRarity[rarity]
	return u.CoinCost[level+relLv]
}

func (u upgrade) CoinCostToLevel(rarity CardRarity, from, to int) int {
	cost := 0
	relLv := u.RelativeLvByRarity[rarity]
	for i := from + relLv; i < to+relLv; i++ {
		cost += u.CoinCost[i]
	}
	return cost
}

func (u upgrade) IsLevelMax(rarity CardRarity, level int) bool {
	if level+u.RelativeLvByRarity[rarity]+1 < LevelMax {
		return false
	}
	return true
}
