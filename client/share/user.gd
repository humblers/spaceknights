extends Node

const CONFIG_FILE = "user://settings.cfg"

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
