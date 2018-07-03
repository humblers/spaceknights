extends Node2D

func _ready():
	$Lobby.connect("pressed", self, "back_to_lobby")

func show_result(data):
	$Win.visible = data.Winner == global.team
	$Lose.visible = not data.Winner == global.team	
	for team in ["Home", "Visitor"]:
		var node = $MyTeam if global.team == team else $EnemyTeam
		var stat = data.Stats[team]
		for key in stat:
			node.get_node(key).set_text(str(stat[key]))

func back_to_lobby():
	get_tree().change_scene("res://lobby.tscn")