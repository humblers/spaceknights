package data

var Upgrade = struct {
	RelativeLvByRarity map[CardRarity]int
	CardCost           []int
	GoldCost           []int
}{
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
	GoldCost: []int{
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

func CardCostNextLevel(level int) int {
	return Upgrade.CardCost[level]
}

func CardCostToLevel(from, to int) int {
	cost := 0
	for i := from; i < to; i++ {
		cost += Upgrade.CardCost[i]
	}
	return cost
}

func GoldCostNextLevel(name string, level int) int {
	relLv := Upgrade.RelativeLvByRarity[Cards[name].Rarity]
	return Upgrade.GoldCost[level+relLv]
}

func GoldCostToLevel(name string, from, to int) int {
	cost := 0
	relLv := Upgrade.RelativeLvByRarity[Cards[name].Rarity]
	for i := from + relLv; i < to+relLv; i++ {
		cost += Upgrade.GoldCost[i]
	}
	return cost
}
