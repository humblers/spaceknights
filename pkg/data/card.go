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
		Type:   KnightCard,
		Cost:   5000,
		Unit:   "archengineer",
		Rarity: Rare,
	},
	"archers": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "archer",
		Count:   2,
		OffsetX: []int{-40, 40},
		OffsetY: []int{0, 0},
		Rarity:  Common,
	},
	"archsapper": Card{
		Type:   KnightCard,
		Cost:   3000,
		Unit:   "archsapper",
		Rarity: Common,
	},
	"astra": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "astra",
		Rarity: Legendary,
	},
	"berserker": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "berserker",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"blaster": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "blaster",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
	},
	"champion": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "champion",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"drillram": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "drillram",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"enforcer": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "enforcer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"felhound": Card{
		Type:    SquireCard,
		Cost:    2000,
		Unit:    "felhound",
		Count:   5,
		OffsetX: []int{-60, 0, 60, -30, 30},
		OffsetY: []int{-30, -30, -30, 30, 30},
		Rarity:  Common,
	},
	"footmans": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "footman",
		Count:   4,
		OffsetX: []int{-30, 30, -30, 30},
		OffsetY: []int{-30, -30, 30, 30},
		Rarity:  Common,
	},
	"frost": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "frost",
		Rarity: Epic,
	},
	"gargoyles": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "gargoyle",
		Count:   3,
		OffsetX: []int{-20, 20, 0},
		OffsetY: []int{20, 20, 0},
		Rarity:  Common,
	},
	"gargoylehorde": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "gargoyle",
		Count:   6,
		OffsetX: []int{-40, 0, 40, -40, 0, 40},
		OffsetY: []int{-20, -20, -20, 20, 20, 20},
		Rarity:  Common,
	},
	"gargoyleking": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "gargoyleking",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"giant": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "giant",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"ironcoffin": Card{
		Type:   KnightCard,
		Cost:   5000,
		Unit:   "ironcoffin",
		Rarity: Rare,
	},
	"jouster": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "jouster",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"judge": Card{
		Type:   KnightCard,
		Cost:   3000,
		Unit:   "judge",
		Rarity: Common,
	},
	"lancer": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "lancer",
		Rarity: Epic,
	},
	"legion": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "legion",
		Rarity: Rare,
	},
	"micromissile": Card{
		Type:    SquireCard,
		Cost:    1000,
		Unit:    "micromissile",
		Count:   12,
		OffsetX: []int{20, 60, -20, -60, 20, 60, -20, -60, 20, 60, -20, -60},
		OffsetY: []int{-40, -40, -40, -40, 0, 0, 0, 0, 40, 40, 40, 40},
		Rarity:  Common,
	},
	"nagmash": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "nagmash",
		Rarity: Epic,
	},
	"ogre": Card{
		Type:    SquireCard,
		Cost:    7000,
		Unit:    "ogre",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"panzerkunstler": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "panzerkunstler",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"pixie": Card{
		Type:    SquireCard,
		Cost:    1000,
		Unit:    "pixie",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Rare,
	},
	"pixieking": Card{
		Type:   KnightCard,
		Cost:   3000,
		Unit:   "pixieking",
		Rarity: Rare,
	},
	"psabu": Card{
		Type:    SquireCard,
		Cost:    7000,
		Unit:    "psabu",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Legendary,
	},
	"sentry": Card{
		Type:    SquireCard,
		Cost:    2000,
		Unit:    "sentry",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Common,
	},
	"shadowvision": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "shadowvision",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
	"starfire": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "starfire",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
	},
	"threestarfires": Card{
		Type:    SquireCard,
		Cost:    9000,
		Unit:    "starfire",
		Count:   3,
		OffsetX: []int{-60, 60, 0},
		OffsetY: []int{60, 60, 0},
		Rarity:  Rare,
	},
	"tombstone": Card{
		Type:   KnightCard,
		Cost:   6000,
		Unit:   "tombstone",
		Rarity: Rare,
	},
	"trainee": Card{
		Type:    SquireCard,
		Cost:    2000,
		Unit:    "trainee",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Rare,
	},
	"wasp": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "wasp",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
	},
}
