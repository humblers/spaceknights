extends Player

export(NodePath) onready var knightbutton_left = get_node(knightbutton_left) if knightbutton_left else null
export(NodePath) onready var knightbutton_right = get_node(knightbutton_right) if knightbutton_right else null

var id
var color
var input_sent_cards = []		# input sent but not used cards
var focused_hand_index = -1

func Init(playerData, game):
	.Init(playerData, game)
	id = playerData.Id
	color = team
	if game.team_swapped:
		color = "Blue" if team == "Red" else "Red"
	init_deck()
	for card in hand:
		if card.Type == data.KnightCard:
			if card.Side == "Left" and knightbutton_left:
				knightbutton_left.visible = true
			elif card.Side == "Right" and knightbutton_right:
				knightbutton_right.visible = true
	event.connect("%sHandFocused" % color, self, "handFocused")
	event.emit_signal("%sPlayerInitialized" % color, self)

func Update():
	.Update()
	update_energy()
	event.emit_signal("%sUpdateNext" % color, drawTimer <= 0)

func drawCard(index):
	.drawCard(index)
	event.emit_signal("%sSetHand%d" % [color, index+1], hand[index])
	event.emit_signal("%sSetNext" % color, pending[0])

func addKnight(name, level, side):
	var knight = .addKnight(name, level, side)
	knight.side = side
	# make invisible to play show animation
	knight.visible = false

func useCard(card, tileX, tileY):
	.useCard(card, tileX, tileY)
	if has_node("AudioStreamPlayer"):
		var sound_path = loading_screen.GetCardReadySoundPath(card)
		$AudioStreamPlayer.stream = loading_screen.LoadResource(sound_path)
		$AudioStreamPlayer.play()

func init_deck():
	for i in len(hand):
		event.emit_signal("%sSetHand%d" % [color, i+1], hand[i])
	event.emit_signal("%sSetNext" % color, pending[0])

func update_energy():
	event.emit_signal("%sEnergyUpdated" % color, get_energy())

func get_energy():
	var current = energy
	for card in input_sent_cards:
		current -= card.Cost
	return current

func removeCardFromHand(index):
	var card = .removeCardFromHand(index)
	for c in input_sent_cards:
		if c.Name == card.Name:
			input_sent_cards.erase(c)
			update_energy()
			break
	event.emit_signal("%sSetHand%d" % [color, index+1], null)

func removeCardFromPending(index):
	.removeCardFromPending(index)
	if index == 0:
		event.emit_signal("%sSetNext" % color, pending[0])

func OnKnightDead(knight):
	.OnKnightDead(knight)

func send_input(card, pos):
	var x = int(pos.x)
	var y = int(pos.y)
	if game.team_swapped:
		x = game.FlipX(x)
		y = game.FlipY(y)
	var tile = game.TileFromPos(x, y)
	var input = {
			"Step": game.step + INPUT_DELAY_STEP,
			"Action": {
				"Id": id,
				"Card": {
					"Name": card.Name,
					"Level": card.Level,
				},
				"TileX": tile[0],
				"TileY": tile[1],
			},
	}
	if game.connected:
		game_client.Send(input)
	else:
		if game.actions.has(input.Step):
			game.actions[input.Step].append(input.Action)
		else:
			game.actions[input.Step] = [input.Action]
	input_sent_cards.append(card)
	update_energy()

func handFocused(index):
	focused_hand_index = index
	for i in range(len(hand)):
		var card = hand[i]
		if card == null:
			continue
		var knight = findKnight(card.Name)
		if knight == null:
			continue
		if i == index - 1:
			knight.skillReady()
		else:
			knight.skillRest()

func hasFocused():
	return focused_hand_index > 0

func focusRelease():
	focused_hand_index = -1