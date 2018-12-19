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
