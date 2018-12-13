package data

var Upgrade = struct {
	RelativeLvRare      int
	RelativeLvEpic      int
	RelativeLvLegendary int
	CardCost            []int
	GoldCost            []int
}{
	RelativeLvRare:      2,
	RelativeLvEpic:      5,
	RelativeLvLegendary: 8,

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
