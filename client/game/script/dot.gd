extends Node2D

var team
var x
var y
var width
var height
var damagePerSec
var remainingStep
var game

func Init(team, x, y, w, h, dps, remain, game):
	self.team = team
	self.x = x
	self.y = y
	width = w
	height = h
	damagePerSec = dps
	remainingStep = remain
	self.game = game
	
	# client only
	var posX = game.World().ToPixel(x)
	var posY = game.World().ToPixel(y)
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
	position = Vector2(posX, posY)
	$AnimationPlayer.play("poison")

func Update():
	if remainingStep % game.STEP_PER_SEC == 0:
		for id in game.UnitIds():
			var u = game.FindUnit(id)
			if u.Team() == team:
				continue
			if InArea(u):
				u.TakeDamage(damagePerSec, "Skill")
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
