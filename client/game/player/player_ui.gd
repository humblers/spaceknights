extends Player

export(NodePath) onready var mothership = get_node(mothership)
export(NodePath) onready var tile = get_node(tile)
export(NodePath) onready var energy_bar = get_node(energy_bar) if energy_bar else null
export(NodePath) onready var unit_ready_sound = get_node(unit_ready_sound) if unit_ready_sound else null

export(NodePath) onready var hand1 = get_node(hand1) if hand1 else null
export(NodePath) onready var hand2 = get_node(hand2) if hand2 else null
export(NodePath) onready var hand3 = get_node(hand3) if hand3 else null
export(NodePath) onready var hand4 = get_node(hand4) if hand4 else null
export(NodePath) onready var next = get_node(next) if next else null

var id
var color
var input_sent_cards = []		# input sent but not used cards

func Init(playerData, game):
	.Init(playerData, game)
	id = playerData.Id
	color = team
	if game.team_swapped:
		color = "Blue" if team == "Red" else "Red"
	if energy_bar:
		energy_bar.max_value = MAX_ENERGY
	init_deck()
	mothership.Init(self)

func Update():
	.Update()
	update_energy()
	if next:
		next.Update(drawTimer <= 0)

func drawCard(index):
	.drawCard(index)
	var node = get("hand%d" % (index+1))
	if node:
		node.Set(hand[index])
	if next:
		next.Set(pending[0])

func addKnight(name, level, side):
	var knight = .addKnight(name, level, side)
	knight.side = side
	# make invisible to play show animation
	knight.visible = false

func useCard(card, tileX, tileY):
	.useCard(card, tileX, tileY)
	if unit_ready_sound:
		if card.Type == data.SquireCard:
			var sound = unit_ready_sound.get_resource(card.Name)
			$AudioStreamPlayer.stream = sound
			$AudioStreamPlayer.play()

func init_deck():
	for i in len(hand):
		var node = get("hand%d" % (i+1))
		if node:
			node.Set(hand[i])
	if next:
		next.Set(pending[0])

func update_energy():
	var energy = get_energy()
	if energy_bar:
		energy_bar.value = energy
	for i in HAND_SIZE:
		var node = get("hand%d" % (i+1))
		if node:
			node.Update(energy)

func get_energy():
	var current = energy
	for card in input_sent_cards:
		current -= card.Cost
	return current

func removeCardFromHand(index):
	.removeCardFromHand(index)
	var node = get("hand%d" % (index+1))
	if node:
		for c in input_sent_cards:
			if c.Name == node.card.Name:
				input_sent_cards.erase(c)
				update_energy()
				break
		node.Set(null)

func removeCardFromPending(index):
	.removeCardFromPending(index)
	if index == 0:
		if next:
			next.Set(pending[0])
	
func OnKnightDead(knight):
	.OnKnightDead(knight)
	mothership.Destroy(knight.side)
	tile.Expand(color, knight.side)

func OnKnightHalfDamaged(knight):
	mothership.PartialDestroy(knight.side)

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
		tcp.Send(input)
	else:
		if game.actions.has(input.Step):
			game.actions[input.Step].append(input.Action)
		else:
			game.actions[input.Step] = [input.Action]
	input_sent_cards.append(card)
	update_energy()
