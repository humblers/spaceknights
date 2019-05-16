extends Node

const DECK_COUNT = 5
const KNIGHT_SIDES = ["center", "left", "right"]
const SQUIRE_COUNT = 6
const CONFIG_FILE_NAME = "user://settings.cfg"

var HumblerToken = ""
var IssuedAt = 0

var locale

var Id
var Name
var Level
var Exp
var Galacticoin
var Dimensium
var Cards
var DeckSlots
var DeckSelected
var Rank = 25
var Medal = 0
var FreeChest
var MedalChest
var BattleChestSlots
var BattleChestOrder = 0

func _ready():
	randomize()		# set global random seed
	# load or set locale
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
	user.locale = config.get_value("locale", "language")
	if user.locale == null:
		user.locale = OS.get_locale().split("_")[0]
		if err in [OK, ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN]:
			config.set_value("locale", "language", user.locale)
			config.save(user.CONFIG_FILE_NAME)
	TranslationServer.set_locale(user.locale)

func ShouldSwapTeam(cfg):
	for p in cfg.Players:
		if p.Id == Id and not p.Team == "Blue":
			return true
	return false

func CardInDeck(card):
	for c in  DeckSlots[DeckSelected]:
		if c.Name == card:
			return true
	return false
