extends Reference

var dict = {
	"RelativeLvByRarity": {
		data.Common:    0,
		data.Rare:      2,
		data.Epic:      5,
		data.Legendary: 8,
	},
	
	"CardCost": [
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
	],
	"CoinCost": [
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
	],
}

func _init(dict=null):
	if dict != null:
		self.dict = dict

func CardCostNextLevel(level):
	return dict.CardCost[level]

func CardCostToLevel(from, to):
	var cost = 0
	for lv in range(from, to):
		cost += dict.CardCost[lv]
	return cost

func CoinCostNextLevel(rarity, level):
	var relLv = dict.RelativeLvByRarity[rarity]
	return dict.CoinCost[level + relLv]

func CoinCostToLevel(rarity, from, to):
	var cost = 0
	var relLv = dict.RelativeLvByRarity[rarity]
	for lv in range(from + relLv, to + relLv):
		cost += dict.CoinCost[lv]
	return cost

func IsLevelMax(rarity, level):
	if level + dict.RelativeLvByRarity[rarity] + 1 < data.LevelMax:
		return false
	return true
