package data

type CardRarity string

const (
	Common CardRarity = "Common"
	Rare   CardRarity = "Rare"
	Epic   CardRarity = "Epic"
	Legend CardRarity = "Legend"
)

type Card struct {
	Cost    int
	Unit    string
	Count   int
	OffsetX []int
	OffsetY []int
	Rarity  CardRarity
}

var Cards = map[string]Card{
	"archengineer": Card{
		Cost:    5000,
		Unit:    "archengineer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"archers": Card{
		Cost:    3000,
		Unit:    "archer",
		Count:   2,
		OffsetX: []int{-40, 40},
		OffsetY: []int{0, 0},
		Rarity:  Common,
	},
	"archsapper": Card{
		Cost:    3000,
		Unit:    "archsapper",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
	},
	"astra": Card{
		Cost:    4000,
		Unit:    "astra",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"berserker": Card{
		Cost:    4000,
		Unit:    "berserker",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"blaster": Card{
		Cost:    3000,
		Unit:    "blaster",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"champion": Card{
		Cost:    4000,
		Unit:    "champion",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"drillram": Card{
		Cost:    4000,
		Unit:    "drillram",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"enforcer": Card{
		Cost:    4000,
		Unit:    "enforcer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"felhound": Card{
		Cost:    2000,
		Unit:    "felhound",
		Count:   5,
		OffsetX: []int{-60, 0, 60, -30, 30},
		OffsetY: []int{-30, -30, -30, 30, 30},
		Rarity:  Common,
	},
	"footmans": Card{
		Cost:    5000,
		Unit:    "footman",
		Count:   4,
		OffsetX: []int{-30, 30, -30, 30},
		OffsetY: []int{-30, -30, 30, 30},
		Rarity:  Common,
	},
	"frost": Card{
		Cost:    4000,
		Unit:    "frost",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"gargoylehorde": Card{
		Cost:    5000,
		Unit:    "gargoyle",
		Count:   6,
		OffsetX: []int{-40, 0, 40, -40, 0, 40},
		OffsetY: []int{-20, -20, -20, 20, 20, 20},
		Rarity:  Common,
	},
	"gargoyleking": Card{
		Cost:    3000,
		Unit:    "gargoyleking",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"giant": Card{
		Cost:    5000,
		Unit:    "giant",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"ironcoffin": Card{
		Cost:    5000,
		Unit:    "ironcoffin",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"jouster": Card{
		Cost:    5000,
		Unit:    "jouster",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"judge": Card{
		Cost:    3000,
		Unit:    "judge",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"lancer": Card{
		Cost:    5000,
		Unit:    "lancer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"legion": Card{
		Cost:    4000,
		Unit:    "legion",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"nagmash": Card{
		Cost:    4000,
		Unit:    "nagmash",
		Count:   4,
		OffsetX: []int{-30, 30, -30, 30},
		OffsetY: []int{-30, -30, 30, 30},
		Rarity:  Common,
	},
	"ogre": Card{
		Cost:    7000,
		Unit:    "ogre",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"panzerkunstler": Card{
		Cost:    5000,
		Unit:    "panzerkunstler",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"pixie": Card{
		Cost:    1000,
		Unit:    "pixie",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Common,
	},
	"pixieking": Card{
		Cost:    3000,
		Unit:    "pixieking",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"psabu": Card{
		Cost:    7000,
		Unit:    "psabu",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"sentry": Card{
		Cost:    2000,
		Unit:    "sentry",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Common,
	},
	"shadowvision": Card{
		Cost:    4000,
		Unit:    "shadowvision",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"starfire": Card{
		Cost:    4000,
		Unit:    "starfire",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"threestarfires": Card{
		Cost:    9000,
		Unit:    "starfire",
		Count:   3,
		OffsetX: []int{-60, 60, 0},
		OffsetY: []int{60, 60, 0},
		Rarity:  Common,
	},
	"tombstone": Card{
		Cost:    7000,
		Unit:    "tombstone",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"trainee": Card{
		Cost:    2000,
		Unit:    "trainee",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Common,
	},
	"wasp": Card{
		Cost:    5000,
		Unit:    "wasp",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
}