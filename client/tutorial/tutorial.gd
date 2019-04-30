extends "res://game/game.gd"

enum PHASES {
	INITIAL,
	REQUEST_ARCHERS,
	REQUEST_GIANT_GARGOYLE,
	REQUEST_BERSERKER,
	HUNT_GIANT_GARGOYLE,
	REMIND_ANTI_BARRIER,
	REQUEST_RANGE_SQUIRES,
	REQUEST_GARGOYLES,
	EXPLAIN_ENERGY_BOOST,
	REMIND_POSITION_STRATEGY,
	REQUEST_FOOTMANS_WAVE,
	REQUEST_FIREBALL,
	TO_THE_VICTORY,
}
const RED_PLAYER_CARD_POS_X = 500
const RED_PLAYER_CARD_POS_Y = 400
const GIANT_GARGOYLE_REQUEST_AFTER = 20
const GIANT_GARGOYLE_SHIELD_MULTIPLIER = 1000
const GIANT_GARGOYLE_SHIELD_REGEN_PER_STEP = INF
const FOOTMAN_WAVE_COUNT = 3
const TUTOR_USE_RANDOM_CARD_POOL = ["archers", "starfire", "footmans"]
const TUTOR_USE_RANDOM_CARD_MIN_DELAY = 2.0
const TUTOR_USE_RANDOM_CARD_MAX_DELAY = 10.0

onready var phase = PHASES.INITIAL

func _enter_tree():
	cfg = {
		"Id": "TUTORIAL",
		"MapName": "Thanatos",
		"Players": [
			{
				"Id": "Student",
				"Team": "Blue",
				"Deck": [
					{"Name": "archers", "Level": 0},
					{"Name": "berserker", "Level": 0},
					{"Name": "gargoyles", "Level": 0},
					{"Name": "legion", "Level": 0, "Side": "Right"},
					{"Name": "archsapper", "Level": 0, "Side": "Left"},
					{"Name": "judge", "Level": 0, "Side": "Center"},
				],
			},
			{
				"Id": "Tutor",
				"Team": "Red",
				"Deck": [
					{"Name": "archsapper", "Level": 0, "Side": "Left"},
					{"Name": "legion", "Level": 0, "Side": "Right"},
					{"Name": "judge", "Level": 0, "Side": "Center"},
				],
			}
		],
	}

func _ready():
	event.connect("StudentUseCard", self, "studentCardUsed")

func Update(state):
	.Update(state)
	match phase:
		PHASES.INITIAL:
			if opening_anim.IsFinished():
				ForwardToNextPhase()
		PHASES.REQUEST_ARCHERS:
			if step / data.StepPerSec >= GIANT_GARGOYLE_REQUEST_AFTER:
				ForwardToNextPhase()
		PHASES.HUNT_GIANT_GARGOYLE:
			if FindGiantGargoyle() == null:
				ForwardToNextPhase()
		PHASES.REQUEST_GARGOYLES, PHASES.EXPLAIN_ENERGY_BOOST:
			if isTutorRemainOnlyKnights():
				event.emit_signal("TransmissionOff")
				ForwardToPhase(PHASES.REMIND_POSITION_STRATEGY)

func AddUnit(name, level, posX, posY, player):
	unitCounter += 1
	var id = unitCounter
	var node = $Resource/Unit.get_resource(name).instance()
	node.Init(id, level, posX, posY, self, player)
	$BattleField/Unit.add_child(node)
	units[id] = node
	return node

func Over():
	var over = .Over()
	if over:
		var config = ConfigFile.new()
		var err = config.load(user.CONFIG_FILE_NAME)
		if err != OK:
			print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
			assert(err in [ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN])
		config.set_value("gameflag", "tutorial_skip", true)
		config.save(user.CONFIG_FILE_NAME)
	return over

func ForwardToNextPhase():
	ForwardToPhase(phase + 1)

func ForwardToPhase(phase):
	self.phase = phase
	event.emit_signal("PhaseChanged", phase, PHASES)
	match phase:
		PHASES.REMIND_ANTI_BARRIER, PHASES.REMIND_POSITION_STRATEGY:
			yield(event, "TransmissionTerminated")
			ForwardToNextPhase()

func FindGiantGargoyle():
	for id in units.keys():
		var unit = units[id]
		if unit.name_ == "giant_gargoyle":
			return unit
	return null

func EnergyBoostEnabled():
	return phase >= PHASES.EXPLAIN_ENERGY_BOOST

func IsKnightInvincible():
	return phase < PHASES.TO_THE_VICTORY

func studentCardUsed(card):
	match phase:
		PHASES.REQUEST_BERSERKER:
			if card.Name == "berserker":
				event.emit_signal("MarkOff")
				ForwardToNextPhase()
		PHASES.REQUEST_GARGOYLES:
			if card.Name == "gargoyles":
				event.emit_signal("MarkOff")
				ForwardToNextPhase()
		PHASES.REQUEST_FIREBALL:
			if card.Name == "legion":
				event.emit_signal("MarkOff")
				ForwardToNextPhase()

func isTutorRemainOnlyKnights():
	for id in units.keys():
		var unit = units[id]
		if unit.team == "Red" and unit.Type() != data.Knight:
			return false
	return true

func update_energy_boost():
	var enabled = EnergyBoostEnabled()
	boost_fx.visible = enabled
	boost_ui.visible = enabled
