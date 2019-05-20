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
	Name    string     `json:",omitempty"`
	Type    CardType   `json:",omitempty"`
	Cost    int        `json:",omitempty"`
	Unit    string     `json:",omitempty"`
	Count   int        `json:",omitempty"`
	OffsetX []int      `json:",omitempty"`
	OffsetY []int      `json:",omitempty"`
	Rarity  CardRarity `json:",omitempty"`
	Arena   Arena      `json:",omitempty"`

	// variant
	Level   int        `json:",omitempty"`
	Holding int        `json:",omitempty"`
	Side    KnightSide `json:",omitempty"`
}

func NewCard(c Card) *Card {
	info := Cards[c.Name]
	return &Card{
		Name:    c.Name,
		Type:    info.Type,
		Cost:    info.Cost,
		Unit:    info.Unit,
		Count:   info.Count,
		OffsetX: info.OffsetX,
		OffsetY: info.OffsetY,
		Rarity:  info.Rarity,
		Arena:   info.Arena,
		Level:   c.Level,
		Holding: c.Holding,
		Side:    c.Side,
	}
}

func (c *Card) TileNum() (int, int) {
	nx, ny := 1, 1
	if c.Type == KnightCard {
		skill := Units[c.Name]["skill"].(map[string]interface{})["wing"].(map[string]interface{})
		if name, ok := skill["unit"]; ok {
			name := name.(string)
			if Units[name]["type"] == Building {
				nx = Units[name]["tilenumx"].(int)
				ny = Units[name]["tilenumy"].(int)
			}
		}
	}
	return nx, ny
}

func (c *Card) IsSpell() bool {
	if c.Type == KnightCard {
		skill := Units[c.Name]["skill"].(map[string]interface{})["wing"].(map[string]interface{})
		if name, ok := skill["unit"]; ok {
			name := name.(string)
			if Units[name]["type"] == Building {
				return false
			} else {
				return true
			}
		} else {
			return true
		}
	} else {
		return false
	}
}

var Cards = map[string]Card{
	"absorber": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "absorber",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Legendary,
		Arena:   Thanatos,
	},
	"archengineer": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "archengineer",
		Rarity: Rare,
		Arena:  Thanatos,
	},
	"archers": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "archer",
		Count:   2,
		OffsetX: []int{-40, 40},
		OffsetY: []int{0, 0},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"archmage": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "archmage",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"archsapper": Card{
		Type:   KnightCard,
		Cost:   2000,
		Unit:   "archsapper",
		Rarity: Common,
		Arena:  Thanatos,
	},
	"astra": Card{
		Type:   KnightCard,
		Cost:   3000,
		Unit:   "astra",
		Rarity: Legendary,
		Arena:  Thanatos,
	},
	"azero": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "azero",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Legendary,
		Arena:   Thanatos,
	},
	"berserker": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "berserker",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"blaster": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "blaster",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"buran": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "buran",
		Rarity: Rare,
		Arena:  Thanatos,
	},
	"champion": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "champion",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
	"drillram": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "drillram",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"enforcer": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "enforcer",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"felhounds": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "felhound",
		Count:   2,
		OffsetX: []int{-40, 40},
		OffsetY: []int{0, 0},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"footmans": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "footman",
		Count:   4,
		OffsetX: []int{-30, 30, -30, 30},
		OffsetY: []int{-30, -30, 30, 30},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"frost": Card{
		Type:   KnightCard,
		Cost:   2000,
		Unit:   "frost",
		Rarity: Epic,
		Arena:  Thanatos,
	},
	"gargoyles": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "gargoyle",
		Count:   3,
		OffsetX: []int{-20, 20, 0},
		OffsetY: []int{20, 20, 0},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"gargoylesquad": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "gargoyle",
		Count:   6,
		OffsetX: []int{-40, 0, 40, -40, 0, 40},
		OffsetY: []int{-20, -20, -20, 20, 20, 20},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"gargoyleking": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "gargoyleking",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"giant": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "giant",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"heavymissiles": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "heavymissile",
		Count:   3,
		OffsetX: []int{-40, 40, 0},
		OffsetY: []int{40, 40, 0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"ironcoffin": Card{
		Type:   KnightCard,
		Cost:   4000,
		Unit:   "ironcoffin",
		Rarity: Rare,
		Arena:  Thanatos,
	},
	"jouster": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "jouster",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
	"judge": Card{
		Type:   KnightCard,
		Cost:   2000,
		Unit:   "judge",
		Rarity: Common,
		Arena:  Thanatos,
	},
	"lancer": Card{
		Type:   KnightCard,
		Cost:   3000,
		Unit:   "lancer",
		Rarity: Epic,
		Arena:  Thanatos,
	},
	"legion": Card{
		Type:   KnightCard,
		Cost:   3000,
		Unit:   "legion",
		Rarity: Rare,
		Arena:  Thanatos,
	},
	"micromissiles": Card{
		Type:    SquireCard,
		Cost:    3000,
		Unit:    "micromissile",
		Count:   12,
		OffsetX: []int{20, 60, -20, -60, 20, 60, -20, -60, 20, 60, -20, -60},
		OffsetY: []int{-40, -40, -40, -40, 0, 0, 0, 0, 40, 40, 40, 40},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"nagmash": Card{
		Type:   KnightCard,
		Cost:   3000,
		Unit:   "nagmash",
		Rarity: Rare,
		Arena:  Thanatos,
	},
	"nukemissile": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "nukemissile",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
	"ogre": Card{
		Type:    SquireCard,
		Cost:    7000,
		Unit:    "ogre",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
	"panzerkunstler": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "panzerkunstler",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
	"pixies": Card{
		Type:    SquireCard,
		Cost:    1000,
		Unit:    "pixie",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"pixieking": Card{
		Type:   KnightCard,
		Cost:   2000,
		Unit:   "pixieking",
		Rarity: Rare,
		Arena:  Thanatos,
	},
	"psabu": Card{
		Type:    SquireCard,
		Cost:    7000,
		Unit:    "psabu",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Legendary,
		Arena:   Thanatos,
	},
	"sentries": Card{
		Type:    SquireCard,
		Cost:    2000,
		Unit:    "sentry",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Common,
		Arena:   Thanatos,
	},
	"shadowvision": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "shadowvision",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
	"starfire": Card{
		Type:    SquireCard,
		Cost:    4000,
		Unit:    "starfire",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"starfiresquadron": Card{
		Type:    SquireCard,
		Cost:    9000,
		Unit:    "starfire",
		Count:   3,
		OffsetX: []int{-60, 60, 0},
		OffsetY: []int{60, 60, 0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"tombstone": Card{
		Type:   KnightCard,
		Cost:   5000,
		Unit:   "tombstone",
		Rarity: Rare,
		Arena:  Thanatos,
	},
	"trainees": Card{
		Type:    SquireCard,
		Cost:    2000,
		Unit:    "trainee",
		Count:   3,
		OffsetX: []int{-30, 30, 0},
		OffsetY: []int{30, 30, 0},
		Rarity:  Rare,
		Arena:   Thanatos,
	},
	"valkyrie": Card{
		Type:   KnightCard,
		Cost:   1000,
		Unit:   "valkyrie",
		Rarity: Common,
		Arena:  Thanatos,
	},
	"voidcreeper": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "voidcreeper",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
	"wasp": Card{
		Type:    SquireCard,
		Cost:    5000,
		Unit:    "wasp",
		Count:   1,
		OffsetX: []int{0},
		OffsetY: []int{0},
		Rarity:  Epic,
		Arena:   Thanatos,
	},
}
