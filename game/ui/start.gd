extends Node

var player1_skill_queue = []
var player1_type = -1

var player2_skill_queue = []
var player2_type = -1

onready var blue_score = 0
onready var red_score = 0
onready var blue_hp = 0
onready var red_hp = 0
onready var blue_life = 0
onready var red_life = 0
onready var gameover = false

func _ready():
	var player_data = File.new()
	if not player_data.file_exists("user://player_data.dat"):
		return

	var cur_line = {}
	player_data.open("user://player_data.dat", File.READ)
	while(not player_data.eof_reached()):
		cur_line.parse_json(player_data.get_line())
		for key in cur_line:
			set(key, cur_line[key])

func save_player_data(p1_button_idx=null, p2_button_idx=null):
	var datas = {
		"player1_skill_queue" : player1_skill_queue,
		"player1_type" : p1_button_idx if p1_button_idx != null else player1_type,
		"player2_skill_queue" : player2_skill_queue,
		"player2_type" : p2_button_idx if p2_button_idx != null else player2_type,
	}
	var player_data = File.new()
	player_data.open("user://player_data.dat", File.WRITE)
	player_data.store_line(datas.to_json())
	player_data.close()
