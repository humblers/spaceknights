extends Node

var game
var tileOccupied

func Init(game):
	self.game = game

func GetRect(x, y, w, h):
	if w%2 == 0 or h%2 == 0:
		print("not implemented even number of tile occupy")
		return
	w = w / 2
	h = h / 2
	return { "t": y-h, "b":y+h, "l":x-w, "r":x+w }

func Occupy(tr):
	if tileOccupied != null:
		return "occupier already occupy tile: {t},{b},{l},{r}".format(tileOccupied)

	var gOccupied = game.OccupiedTiles()
	for occupied in gOccupied.keys():
		if game.intersect_tilerect(occupied, tr):
			return "tile intersects, occupied: {t},{b},{l},{r}".format(occupied) + ", new: {t},{b},{l},{r}".format(tr)
	tileOccupied = tr
	gOccupied[tileOccupied] = true
	return null

func Occupied():
	return tileOccupied

func Release():
	var gOccupied = game.OccupiedTiles()
	if gOccupied.has(tileOccupied):
		gOccupied.erase(tileOccupied)
	tileOccupied = null