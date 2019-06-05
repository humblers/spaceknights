#extends "res://game/offline/single/game.gd"
extends "res://game/game.gd"

enum PHASES {
	INITIAL,
	FOOTMANS,
	END,
}

onready var phase = PHASES.INITIAL

func _enter_tree():
	cfg = {
		"Id": "TUTORIAL",
		"MapName": "Thanatos",
		"Players": [
			{
				"Id": "Hero",
				"Team": "Blue",
				"Rank": 25,
				"Deck": [
					{"Name": "archers", "Level": 4},
					{"Name": "berserker", "Level": 4},
					{"Name": "footmans", "Level": 4},
					{"Name": "gargoylesquad", "Level": 4},
					{"Name": "micromissiles", "Level": 0},
					{"Name": "panzerkunstler", "Level": 0},
					{"Name": "legion", "Level": 0, "Side": "Right"},
					{"Name": "archsapper", "Level": 0, "Side": "Left"},
					{"Name": "valkyrie", "Level": 0, "Side": "Center"},
				],
			},
			{
				"Id": "Villain",
				"Team": "Red",
				"Rank": 0,
				"Deck": [
					{"Name": "archers", "Level": 0},
					{"Name": "berserker", "Level": 0},
					{"Name": "footmans", "Level": 0},
					{"Name": "gargoylesquad", "Level": 0},
					{"Name": "legion", "Level": 0, "Side": "Right"},
					{"Name": "archsapper", "Level": 0, "Side": "Left"},
					{"Name": "lancer", "Level": 0, "Side": "Center"},
				],
			}
		],
	}
	
func _ready():
	event.connect("StudentUseCard", self, "studentCardUsed")
	players["Hero"].rival_knight = FindUnit(players["Villain"].knightIds["Center"])
	players["Hero"].knight.setRival(players["Hero"].rival_knight)
	players["Villain"].rival_knight = FindUnit(players["Hero"].knightIds["Center"])
	players["Villain"].knight.setRival(players["Villain"].rival_knight)
	#rival_knight = game.FindUnit(game.FindPlayer(opponentTeam()).knightIds["Center"])
	#knight.setRival(rival_knight)
	

func Update(state):
	.Update(state)
	match phase:
		PHASES.INITIAL:
			if opening_anim.IsFinished():
				ForwardToNextPhase()
#		PHASES.REQUEST_ARCHERS, PHASES.COMPLIMENT_ARCHERS:
#			if step / data.StepPerSec >= GIANT_GARGOYLE_REQUEST_AFTER:
#				ForwardToPhase(PHASES.REQUEST_GIANT_GARGOYLE)
#		PHASES.HUNT_GIANT_GARGOYLE:
#			if FindGiantGargoyle() == null:
#				ForwardToNextPhase()
#		PHASES.REQUEST_BOOSTED_SQUIRES:
#			if isTutorRemainOnlyKnights():
#				event.emit_signal("TransmissionOff")
#				ForwardToPhase(PHASES.COMPLIMENT_BOOST)
#		PHASES.REMIND_POSITION_STRATEGY:
#			if isTutorRemainOnlyKnights():
#				event.emit_signal("TransmissionOff")
#				ForwardToNextPhase()

func AddUnit(name, level, posX, posY, player):
	unitCounter += 1
	var id = unitCounter
	var node = $Resource/Unit.get_resource(name).instance()
	node.Init(id, level, posX, posY, self, player)
	if node.Type() == data.Squire:
		node.scale = Vector2(1.2,1.2)
	$BattleField/Unit.add_child(node)
	units[id] = node
	return node

func Over():
	var over = .Over()
	if over and phase != PHASES.END:
		var my_team = $Players/Blue.team
#		var enemy_team = "Blue" if my_team == "Red" else "Red"
#		var my_score = score(my_team)
#		var enemy_score = score(enemy_team)
#		if my_score > enemy_score:
#			ForwardToPhase(PHASES.WIN)
#		elif my_score < enemy_score:
#			ForwardToPhase(PHASES.LOSE)
#		else:
#			ForwardToPhase(PHASES.LOSE)
		return false
	
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
		PHASES.FOOTMANS:
			pass
#		PHASES.HELLO, PHASES.EXPLAIN_BERSERKER, PHASES.REMIND_ANTI_BARRIER, PHASES.EXPLAIN_ENERGY_BOOST, PHASES.COMPLIMENT_BOOST, PHASES.COMPLIMENT_FIREBALL:
#			yield(event, "TransmissionTerminated")
#			ForwardToNextPhase()
#		PHASES.WIN, PHASES.LOSE:
#			yield(event, "TransmissionTerminated")
#			ForwardToPhase(PHASES.END)

func FindGiantGargoyle():
	for id in units.keys():
		var unit = units[id]
		if unit.name_ == "giant_gargoyle":
			return unit
	return null

func EnergyBoostEnabled():
	return false #phase >= PHASES.EXPLAIN_ENERGY_BOOST

func IsKnightInvincible():
	return false #phase < PHASES.TO_THE_VICTORY

func studentCardUsed(card):
	match phase:
		PHASES.REQUEST_ARCHERS:
			if card.Name == "archers":
				event.emit_signal("MarkOff")
				ForwardToNextPhase()
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