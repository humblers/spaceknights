package data

const StepPerSec = 10
const PlayTime = 180 * StepPerSec
const OverTime = 60 * StepPerSec
const EnergyBoostAfter = 120 * StepPerSec

const TileSizeInPixel = 50

const InitialDimensium = 1000
const InitialGalacticoin = 0

const DeckSlotSize = 5

const LevelMax = 13
const StatMultiplier = 110

const InitialRank = 25
const MedalsPerRank = 5

const DecreasedDamageRatioOnKnightBuilding = 35

var InitialDeck = []Card{
	Card{Name: "archers"},
	Card{Name: "giant"},
	Card{Name: "footmans"},
	Card{Name: "blaster"},
	Card{Name: "enforcer"},
	Card{Name: "jouster"},
	Card{Name: "archsapper", Side: Left},
	Card{Name: "legion", Side: Center},
	Card{Name: "nagmash", Side: Right},
}

const SquireCountInInitialDeck = 6
const KnightCountInInitialDeck = 3

type Arena int

const ArenaCount = 6
const (
	Thanatos Arena = iota
	Solamante
	Lunatos
	Kinetica
	Karas
	Eoparu
)

func ArenaFromRank(rank int) Arena {
	if rank == 0 {
		return Eoparu
	}
	var idx = ArenaCount - ((rank-1)/5 + 2)
	return Arena(idx)
}
