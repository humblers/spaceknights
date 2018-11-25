extends Node

const CONFIG_FILE = "user://settings.cfg"

const DECK_COUNT = 5
const KNIGHT_SIDES = ["center", "left", "right"]
const SQUIRE_COUNT = 6

var PlatformId

var Id
var Name
var Level
var Exp
var Galacticoin
var Dimensium
var Cards
var Decks
var DeckSelected
var Solo

func ShouldSwapTeam(cfg):
	for p in cfg.Players:
		if p.Id == Id and not p.Team == "Blue":
			return true
	return false

func CardInDeck(card):
	var deck = Decks[DeckSelected]
	for k in deck.Knights:
		if k == card:
			return true
	for t in deck.Troops:
		if t == card:
			return true
	return false