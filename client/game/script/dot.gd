extends Node2D

var team
var x
var y
var width
var height
var damagePerSec
var remainingStep
var damageType
var game

func Hash():
	return djb2.Combine([
		djb2.HashString(team),
		vector.Hash(x, y),
		scalar.Hash(width),
		scalar.Hash(height),
		djb2.HashInt(damagePerSec),
		djb2.HashInt(remainingStep),
		djb2.HashInt(damageType)
	])

func State():
	return {
		"team": team,
		"position": {"X": x, "Y": y},
		"width": width,
		"height": height,
		"damagePerSec": damagePerSec,
		"remainingStep": remainingStep,
		"damageType": damageType,
	}
	
func Init(team, x, y, w, h, dps, remain, damageType, game):
	self.team = team
	self.x = x
	self.y = y
	width = w
	height = h
	damagePerSec = dps
	remainingStep = remain
	self.damageType = damageType
	self.game = game
	
	# client only
	var posX = game.World().ToPixel(x)
	var posY = game.World().ToPixel(y)
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
	position = Vector2(posX, posY)

func Update():
	if remainingStep % data.StepPerSec == 0:
		for id in game.UnitIds():
			var u = game.FindUnit(id)
			if u.Team() == team:
				continue
			if InArea(u):
				u.TakeDamage(damagePerSec, damageType, self)
	remainingStep -= 1

func IsExpired():
	return remainingStep <= 0

func InArea(unit):
	return game.boxVScircle(
		x,
		y,
		unit.PositionX(),
		unit.PositionY(),
		width,
		height,
		unit.Radius())

func Destroy():
	queue_free()
