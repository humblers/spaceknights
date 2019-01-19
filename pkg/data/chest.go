package data

import "encoding/json"

const TimeReductionPerCash = 10 * 60 // seconds
const RequiredMedalsForMedalChest = 10

var CardPool [ArenaCount]map[CardRarity][]string

func init() {
	// init CardPool
	for name, card := range Cards {
		for i := card.Arena; i < ArenaCount; i++ {

			if CardPool[i] == nil {
				CardPool[i] = make(map[CardRarity][]string)
			}
			CardPool[i][card.Rarity] = append(CardPool[i][card.Rarity], name)
		}
	}
}

func RequiredCashForTime(sec int) int {
	cash := sec / TimeReductionPerCash
	if sec%TimeReductionPerCash > 0 {
		cash++
	}
	return cash
}

type Chest struct {
	Name         string
	AcquiredRank int
	AcquiredAt   int64
}

type ChestInfo struct {
	Name           string `json:"-"`
	Duration       int64
	Price          int
	MinCash        int `json:"-"`
	MaxCash        int `json:"-"`
	MinGoldPerCard int
	MaxGoldPerCard int
	NumCards       [ArenaCount]int
	Guaranteed     map[CardRarity][ArenaCount]int
	ExtraCards     map[CardRarity][ArenaCount]float64 `json:"-"`
	BundleMin      int                                `json:"-"`
}

func (c *Chest) String() string {
	b, err := json.Marshal(c)
	if err != nil {
		panic(err)
	}
	return string(b)
}

var Chests = map[string]ChestInfo{
	"Silver": ChestInfo{
		Name:           "Silver",
		Duration:       3600 * 3,
		MinGoldPerCard: 7,
		MaxGoldPerCard: 8,
		NumCards:       [ArenaCount]int{7, 8, 9, 10, 12, 13},
		Guaranteed: map[CardRarity][ArenaCount]int{
			Rare: [ArenaCount]int{0, 0, 1, 1, 1, 1},
		},
		ExtraCards: map[CardRarity][ArenaCount]float64{
			Rare:      [ArenaCount]float64{77.778, 88.889, 0, 11.111, 33.333, 44.444},
			Epic:      [ArenaCount]float64{1.4, 1.6, 1.8, 2, 2.4, 2.6},
			Legendary: [ArenaCount]float64{0, 0.013, 0.026, 0.038, 0.053, 0.065},
		},
		BundleMin: 2,
	},
	"Gold": ChestInfo{
		Name:           "Gold",
		Duration:       3600 * 8,
		MinGoldPerCard: 14,
		MaxGoldPerCard: 16,
		NumCards:       [ArenaCount]int{14, 16, 18, 21, 23, 26},
		Guaranteed: map[CardRarity][ArenaCount]int{
			Rare: [ArenaCount]int{3, 4, 4, 5, 5, 6},
		},
		ExtraCards: map[CardRarity][ArenaCount]float64{
			Rare:      [ArenaCount]float64{50, 0, 50, 25, 75, 50},
			Epic:      [ArenaCount]float64{7, 8, 9, 10.5, 11.5, 13},
			Legendary: [ArenaCount]float64{0, 0.067, 0.129, 0.197, 0.256, 0.325},
		},
		BundleMin: 3,
	},
	"Diamond": ChestInfo{
		Name:           "Diamond",
		Duration:       3600 * 12,
		Price:          250,
		MinGoldPerCard: 5,
		MaxGoldPerCard: 5,
		NumCards:       [ArenaCount]int{89, 93, 97, 101, 105, 109},
		Guaranteed: map[CardRarity][ArenaCount]int{
			Rare: [ArenaCount]int{14, 15, 16, 16, 17, 18},
			Epic: [ArenaCount]int{1, 1, 1, 2, 2, 2},
		},
		ExtraCards: map[CardRarity][ArenaCount]float64{
			Legendary: [ArenaCount]float64{0, 0.194, 0.346, 0.473, 0.583, 0.681},
		},
		BundleMin: 5,
	},
	"D-Matter": ChestInfo{
		Name:           "D-Matter",
		Duration:       3600 * 12,
		Price:          750,
		MinGoldPerCard: 7,
		MaxGoldPerCard: 7,
		NumCards:       [ArenaCount]int{178, 186, 194, 202, 210, 218},
		Guaranteed: map[CardRarity][ArenaCount]int{
			Rare: [ArenaCount]int{35, 37, 38, 40, 42, 43},
			Epic: [ArenaCount]int{5, 6, 6, 6, 7, 7},
		},
		ExtraCards: map[CardRarity][ArenaCount]float64{
			Legendary: [ArenaCount]float64{0, 2, 5, 5, 6.667, 6.667},
		},
		BundleMin: 5,
	},
	"E-Matter": ChestInfo{
		Name:           "E-Matter",
		Duration:       3600 * 12,
		Price:          2000,
		MinGoldPerCard: 12,
		MaxGoldPerCard: 12,
		NumCards:       [ArenaCount]int{260, 270, 280, 290, 300, 310},
		Guaranteed: map[CardRarity][ArenaCount]int{
			Rare:      [ArenaCount]int{52, 54, 56, 58, 60, 62},
			Epic:      [ArenaCount]int{17, 18, 18, 19, 20, 20},
			Legendary: [ArenaCount]int{0, 0, 0, 0, 1, 1},
		},
		ExtraCards: map[CardRarity][ArenaCount]float64{
			Legendary: [ArenaCount]float64{0, 10, 20, 33.333, 0, 0},
		},
		BundleMin: 5,
	},
	"Free": ChestInfo{
		Name:           "Free",
		Duration:       3600 * 4,
		MinCash:        2,
		MaxCash:        4,
		MinGoldPerCard: 7,
		MaxGoldPerCard: 8,
		NumCards:       [ArenaCount]int{5, 6, 7, 8, 9, 11},
		Guaranteed: map[CardRarity][ArenaCount]int{
			Rare: [ArenaCount]int{0, 0, 0, 0, 0, 1},
		},
		ExtraCards: map[CardRarity][ArenaCount]float64{
			Rare:      [ArenaCount]float64{50, 60, 70, 80, 90, 0},
			Epic:      [ArenaCount]float64{2.5, 3, 3.5, 4, 4.5, 5},
			Legendary: [ArenaCount]float64{0, 0.025, 0.05, 0.075, 0.1, 0.125},
		},
		BundleMin: 2,
	},
	"Medal": ChestInfo{
		Name:           "Medal",
		MinCash:        3,
		MaxCash:        5,
		MinGoldPerCard: 14,
		MaxGoldPerCard: 16,
		NumCards:       [ArenaCount]int{27, 32, 37, 42, 46, 51},
		Guaranteed: map[CardRarity][ArenaCount]int{
			Rare: [ArenaCount]int{4, 5, 6, 7, 7, 8},
		},
		ExtraCards: map[CardRarity][ArenaCount]float64{
			Rare:      [ArenaCount]float64{50, 33.333, 16.667, 0, 66.667, 50},
			Epic:      [ArenaCount]float64{22.5, 26.667, 30.833, 35, 38.333, 42.5},
			Legendary: [ArenaCount]float64{0, 0.222, 0.44, 0.656, 0.852, 1.063},
		},
		BundleMin: 4,
	},
}

var ChestOrder = []string{
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"D-Matter",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Diamond",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"D-Matter",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"D-Matter",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Diamond",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Diamond",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"D-Matter",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Diamond",
	"Silver",
	"Silver",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
	"Silver",
	"Gold",
	"Silver",
}
