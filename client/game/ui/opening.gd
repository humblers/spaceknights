extends Control

onready var blue_user_name = $Deckopen/Blue/UserB/Username
onready var blue_leader_name = $Deckopen/Blue/ControlB/Control/UnitnameB
onready var blue_leader_desc = $Deckopen/Blue/ControlB/Control/DescriptB
onready var blue_leader_icon = $Deckopen/Blue/ControlB/KnightBG/KnightB
onready var red_user_name = $Deckopen/Red/UserR/Username
onready var red_leader_name = $Deckopen/Red/ControlR/Control/UnitnameB
onready var red_leader_desc = $Deckopen/Red/ControlR/Control/DescriptB
onready var red_leader_icon = $Deckopen/Red/ControlR/KnightBG/KnightB
onready var anim = $AnimationPlayer

var blue_id
var blue_leader
var red_id
var red_leader

func SetPlayerData(team, id, leader):
	set("%s_id" % [team.to_lower()], int(id))
	set("%s_leader" % [team.to_lower()], leader)

func Play():
	blue_user_name.text = "Imperial-Knight-%03d" % blue_id
	blue_leader_name.SetText("ID_%s" % blue_leader.to_upper())
	blue_leader_desc.SetText("ID_LEADER_SKILL_%s" % blue_leader)
	var path = loading_screen.GetCardIconPathInGame(blue_leader)
	blue_leader_icon.texture = loading_screen.LoadResource(path)
	if red_id == 0:
		var pad = randi() % 5 + 1
		pad *=  1 if randi() % 2 == 0 else -1
		red_id = blue_id + pad
	red_user_name.text = "Imperial-Knight-%03d" % red_id
	red_leader_name.SetText("ID_%s" % red_leader.to_upper())
	red_leader_desc.SetText("ID_LEADER_SKILL_%s" % red_leader)
	path = loading_screen.GetCardIconPathInGame(red_leader)
	red_leader_icon.texture = loading_screen.LoadResource(path)
	anim.play("show")

func IsFinished():
	return not visible