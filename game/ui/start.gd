extends Node

var player1_skill_queue = []
var player1_type = 0

var player2_skill_queue = []
var player2_type = 0

onready var blue_score = 0
onready var red_score = 0
onready var blue_hp = 0
onready var red_hp = 0
onready var gameover = false

func _ready():
	get_tree().change_scene("res://ui/main_menu.tscn")