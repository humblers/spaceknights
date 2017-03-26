extends Node

var player1_skill_queue = []
var player1_type = constants.KNIGHTS.size()

var player2_skill_queue = []
onready var player2_type = constants.KNIGHTS.size()

onready var blue_score = 0
onready var red_score = 0
onready var blue_hp = 0
onready var red_hp = 0
onready var blue_life = 0
onready var red_life = 0
onready var gameover = false

func _ready():
	player1_skill_queue += Globals.get("player1_skill_queue") \
						if Globals.has("player1_skill_queue") else []
	player1_type += Globals.get("player1_type") \
				if Globals.has("player1_type") else -1
	
	player2_skill_queue += Globals.get("player2_skill_queue") \
						if Globals.has("player2_skill_queue") else []
	player2_type += Globals.get("player2_type") \
				if Globals.has("player2_type") else -1
	
	save_changes()

func set_persists_property_with_value(property):
	Globals.set(property, get(property))
	Globals.set_persisting(property, true)
	
func save_changes():
	set_persists_property_with_value("player1_skill_queue")
	set_persists_property_with_value("player1_type")
	
	set_persists_property_with_value("player2_skill_queue")
	set_persists_property_with_value("player2_type")
	
	Globals.save()
