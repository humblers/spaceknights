extends Node

var player1_skill_queue = []
var player1_type = -1

var player2_skill_queue = []
var player2_type = -1

onready var blue_score = 0
onready var red_score = 0
onready var blue_hp = 0
onready var red_hp = 0
onready var gameover = false

func _ready():
	player1_skill_queue += Globals.get("player1_skill_queue") \
						if Globals.has("player1_skill_queue") else []
	player1_type += Globals.get("player1_type") \
				if Globals.has("player1_type") else 0
	
	player2_skill_queue += Globals.get("player2_skill_queue") \
						if Globals.has("player2_skill_queue") else []
	player2_type += Globals.get("player2_type") \
				if Globals.has("player2_type") else 0
	
	save_player_data()

func set_persists_property_with_value(property, value=null):
	if value == null:
		value = get(property)
	Globals.set(property, value)
	Globals.set_persisting(property, true)
	
func save_player_data(p1_button_idx=null, p2_button_idx=null):
	set_persists_property_with_value("player1_skill_queue")
	set_persists_property_with_value("player1_type", p1_button_idx)
	
	set_persists_property_with_value("player2_skill_queue")
	set_persists_property_with_value("player2_type", p2_button_idx)
	
	Globals.save()
