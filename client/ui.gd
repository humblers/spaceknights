extends Node

const MAP_HEIGHT = 560
const BASE_HEIGHT = 50
const TILE_HEIGHT = 20

const TO_THRESHOLD = 0.5

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var winner = get_node("Winner")

var id
var team
var hand

var guide_node
var guide_pos_x

func _ready():
	input.connect("mouse_dragged", self, "move")
	card1.connect("pressed", self, "press_card", [1])
	card2.connect("pressed", self, "press_card", [2])
	card3.connect("pressed", self, "press_card", [3])
	card1.connect("released", self, "release_card", [1])
	card2.connect("released", self, "release_card", [2])
	card3.connect("released", self, "release_card", [3])
	card1.connect("mouse_exit", self, "cancel_card")
	card2.connect("mouse_exit", self, "cancel_card")
	card3.connect("mouse_exit", self, "cancel_card")
	winner.connect("pressed", self, "back_to_lobby")

func _process(delta):
	var threshold = MAP_HEIGHT / 2 + TILE_HEIGHT * 1.5
	var pos = guide_node.get_pos()
	pos.y -= delta * (MAP_HEIGHT - BASE_HEIGHT - threshold) / TO_THRESHOLD
	if pos.y <= threshold:
		pos.y = threshold
	guide_node.set_pos(pos)

func load_icon(name):
	return load("res://icon/" + name + ".png")

func update_changes(game):
	var player = game[global.team][global.id]
	hand = player.Hand
	# update deck and energy
	get_node("Next").set_texture(load_icon(player.Next))
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var card = hand[i - 1]
		node.set_normal_texture(load_icon(card))
	get_node("Energy").set_value(player.Energy)

	if game.has("Winner"):
		input.disconnect("mouse_dragged", self, "move")
		show_winner(game)

func free_guide_node():
	if guide_node:
		guide_node.queue_free()
		guide_node = null

func press_card(i):
	var card = hand[i - 1]
	if card == "archers":
		guide_node = preload("res://unit/archer.tscn").instance()
	elif card == "barbarians":
		guide_node = preload("res://unit/barbarian.tscn").instance()
	guide_node.transform_to_guide_node(Vector2(guide_pos_x, MAP_HEIGHT - BASE_HEIGHT))
	add_child(guide_node)
	set_process(true)

func release_card(i):
	set_process(false)
	kcp.send({ 
	"Use" : {
		"Index" : i,
		"Point" : guide_node.get_pos().y,
		}
	})
	free_guide_node()

func cancel_card():
	set_process(false)
	free_guide_node()

func move(x):
	kcp.send({ "Move" : x })

func back_to_lobby():
	get_tree().change_scene("res://lobby.tscn")

func show_winner(game):
	var text
	if game.Winner == "Draw":
		text = "Draw"
	elif game.Winner == global.team:
		text = "You Win"
	else:
		text = "You Lose"
	winner.set_text(text)
	winner.show()