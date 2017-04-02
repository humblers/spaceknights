extends Node

var preset_knights = {}

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

func update_preset_knight(key, preset):
	preset_knights[key] = preset
	save_player_data()

func save_player_data():
	var datas = {
		"preset_knights" : preset_knights,
	}
	var player_data = File.new()
	player_data.open("user://player_data.dat", File.WRITE)
	player_data.store_line(datas.to_json())
	player_data.close()
