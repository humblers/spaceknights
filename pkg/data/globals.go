package data

const StepPerSec = 10
const PlayTime = 180 * StepPerSec
const OverTime = 60 * StepPerSec
const EnergyBoostAfter = 120 * StepPerSec

const TileSizeInPixel = 50

const InitialDimensium = 100
const InitialGalacticoin = 100

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
	Card{Name: "gargoyles"},
	Card{Name: "enforcer"},
	Card{Name: "jouster"},
	Card{Name: "archsapper", Side: Center},
	Card{Name: "legion", Side: Left},
	Card{Name: "judge", Side: Right},
}

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
