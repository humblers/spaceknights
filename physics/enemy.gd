extends Node2D

onready var game = get_node("..")
var body

func _ready():
	body = Physics.CreateBox(Q.FromInt(0),
		game.PixelToWorldPosition(Vector2(500, 100)),
		game.PixelToWorldValue(25),
		game.PixelToWorldValue(25))
	body.Node = self
	var n = preload("res://box.tscn").instance()
	get_node("box").width = 25
	get_node("box").height = 25
	get_node("box").color = Color(1, 0, 0)