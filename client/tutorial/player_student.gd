extends "res://game/player/player_ui.gd"

var initial_hands

func Init(playerData, game):
	.Init(playerData, game)
	initial_hands = hand.duplicate(true)

func Update():
	if game.EnergyBoostEnabled():
		energy += ENERGY_PER_FRAME * 2
	else:
		energy += ENERGY_PER_FRAME
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	if canDrawCard():
		drawCard(emptyIdx.pop_front())
	else:
		drawTimer -= 1
	update_energy()

func useCard(card, tileX, tileY):
	.useCard(card, tileX, tileY)
	event.emit_signal("StudentUseCard", card)

func drawCard(index):
	var next = initial_hands[index]
	hand[index] = next
	drawTimer = DRAW_INTERVAL
	event.emit_signal("%sSetHand%d" % [color, index+1], hand[index])