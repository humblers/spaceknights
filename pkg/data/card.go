package data

type CardRarity string

const (
	Common    CardRarity = "Common"
	Rare      CardRarity = "Rare"
	Epic      CardRarity = "Epic"
	Legendary CardRarity = "Legendary"
)

type CardType string

const (
	KnightCard CardType = "KnightCard"
	SquireCard CardType = "SquireCard"
)

type KnightSide string

const (
	Left   KnightSide = "Left"
	Center KnightSide = "Center"
	Right  KnightSide = "Right"
)

type Card struct {
	// invariant
	Name    string
	Type    CardType
	Cost    int
	Unit    string
	Count   int
	OffsetX []int
	OffsetY []int
	Rarity  CardRarity

	// variant
	Level   int
	Holding int
	Side    KnightSide
}

var Cards = map[string]Card{
	"archengineer": Card{
		Cost:    5000,
		Unit:    "archengineer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
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
		Rarity:  Common,
	},
	"astra": Card{
		Cost:    4000,
		Unit:    "astra",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Legendary,
	},
	"berserker": Card{
		Cost:    4000,
		Unit:    "berserker",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
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
		Rarity:  Epic,
	},
	"drillram": Card{
		Cost:    4000,
		Unit:    "drillram",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"enforcer": Card{
		Cost:    4000,
		Unit:    "enforcer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
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
		Rarity:  Epic,
	},
	"gargoyles": Card{
		Cost:    3000,
		Unit:    "gargoyle",
		Count:   3,
		OffsetX: []int{-20, 20, 0},
		OffsetY: []int{20, 20, 0},
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
		Rarity:  Rare,
	},
	"giant": Card{
		Cost:    5000,
		Unit:    "giant",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"ironcoffin": Card{
		Cost:    5000,
		Unit:    "ironcoffin",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"jouster": Card{
		Cost:    5000,
		Unit:    "jouster",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
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
		Cost:    4000,
		Unit:    "lancer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"legion": Card{
		Cost:    4000,
		Unit:    "legion",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"micromissile": Card{
		Cost:    1000,
		Unit:    "micromissile",
		Count:   12,
		OffsetX: []int{20, 60, -20, -60, 20, 60, -20, -60, 20, 60, -20, -60},
		OffsetY: []int{-40, -40, -40, -40, 0, 0, 0, 0, 40, 40, 40, 40},
		Rarity:  Common,
	},
	"nagmash": Card{
		Cost:    4000,
		Unit:    "nagmash",
		Count:   4,
		OffsetX: []int{-30, 30, -30, 30},
		OffsetY: []int{-30, -30, 30, 30},
		Rarity:  Epic,
	},
	"ogre": Card{
		Cost:    7000,
		Unit:    "ogre",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"panzerkunstler": Card{
		Cost:    5000,
		Unit:    "panzerkunstler",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"pixie": Card{
		Cost:    1000,
		Unit:    "pixie",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Rare,
	},
	"pixieking": Card{
		Cost:    3000,
		Unit:    "pixieking",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"psabu": Card{
		Cost:    7000,
		Unit:    "psabu",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Legendary,
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
		Rarity:  Epic,
	},
	"starfire": Card{
		Cost:    4000,
		Unit:    "starfire",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"threestarfires": Card{
		Cost:    9000,
		Unit:    "starfire",
		Count:   3,
		OffsetX: []int{-60, 60, 0},
		OffsetY: []int{60, 60, 0},
		Rarity:  Rare,
	},
	"tombstone": Card{
		Cost:    6000,
		Unit:    "tombstone",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"trainee": Card{
		Cost:    2000,
		Unit:    "trainee",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Rare,
	},
	"wasp": Card{
		Cost:    5000,
		Unit:    "wasp",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
}
