extends Node

const DECK_COUNT = 5
const KNIGHT_SIDES = ["center", "left", "right"]
const SQUIRE_COUNT = 6

var http_cookie_str

var PlatformId

var Id
var Name
var Level
var Exp
var Galacticoin
var Dimensium
var Cards
var DeckSlots
var DeckSelected
var Solo

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
