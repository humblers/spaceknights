extends Node

var preset_knights = {}

var player1_knight = {
	"type" : 0,
	"skills" : []
}
var player2_knight = {
	"type" : 0,
	"skills" : []
}

var blue_score = 0
var red_score = 0
var blue_hp = 0
var red_hp = 0
var blue_life = 0
var red_life = 0
var gameover = false

func _ready():
	var player_data = ConfigFile.new()
	var err = player_data.load("user://player_data.cfg")
	for key in player_data.get_section_keys("preset_knights"):
		preset_knights[key] = player_data.get_value("preset_knights", key)
	
func update_preset_knight(key, preset):
	preset_knights[key] = preset
	save_player_data()

func save_player_data():
	var player_data = ConfigFile.new()
	for key in preset_knights:
		player_data.set_value("preset_knights", key, preset_knights[key])
		var err = player_data.save("user://player_data.cfg")
	
func is_opponent(node_a, node_b):
	if node_a.is_in_group("enemy"):
		if node_b.is_in_group("player"):
			return true
	elif node_a.is_in_group("player"):
		if node_b.is_in_group("enemy"):
			return true
	return false
	
func clone(data):
	var to
	if typeof(data) == TYPE_DICTIONARY:
		to = {}
		for key in data:
			to[key] = clone(data[key])
	elif typeof(data) == TYPE_ARRAY:
		to = []
		for value in data:
			to.append(clone(value))
	else:
		to = data
	return to