extends Control

onready var anim = $AnimationPlayer
onready var medal_add_anim = $Result/MedalAddAni
onready var medal_remove_anim = $Result/MedalRemoveAni
onready var rank_number = $Texts/RankNumber
onready var rank_number_up = $Texts/RankNumberUp
onready var rank_number_down = $Texts/RankNumberDown
onready var rank_name = $Texts/RankName
onready var rank_name_up = $Texts/RankNameUp
onready var rank_name_down = $Texts/RankNameDown
onready var rank_icon = $Result/Icon/RankBase/Rank/RankIcon
onready var rank_icon_up = $Result/Icon/RankBase/Rank/RankIcon
onready var rank_icon_down = $Result/Icon/RankBase/Rank/RankIconDown

onready var medal1 = $Result/Icon/Medal/Medals/Medal1
onready var medal2 = $Result/Icon/Medal/Medals/Medal2
onready var medal3 = $Result/Icon/Medal/Medals/Medal3
onready var medal4 = $Result/Icon/Medal/Medals/Medal4
onready var medal5 = $Result/Icon/Medal/Medals/Medal5

onready var chest_name = $Boxopen/Chest/ChestNameBG/ChestName
onready var chest_icon = $Boxopen/Chest/ChestIcon

var medal = 0
var anim_finished = false

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		if anim_finished:
			loading_screen.GoToScene("res://lobby/lobby.tscn")

func Init(rank, medal, chest_order):
	self.medal = medal
	var rank_up = clamp(rank - 1, 0, data.InitialRank)
	var rank_down = clamp(rank + 1, 0, data.InitialRank)
	rank_number.text = str(rank)
	rank_name.text = data.RankNames[rank]
	rank_icon.texture = $ResourcePreloader.get_resource("rank_icon_%d" % rank)
	rank_number_up.text = str(rank_up)
	rank_name_up.text = data.RankNames[rank_up]
	rank_icon_up.texture = $ResourcePreloader.get_resource("rank_icon_%d" % rank_up)
	rank_number_down.text = str(rank_down)
	rank_name_down.text = data.RankNames[rank_down]
	rank_icon_down.texture = $ResourcePreloader.get_resource("rank_icon_%d" % rank_down)
	for i in data.MedalsPerRank:
		var node = get("medal%d" % (i+1))
		if i < medal:
			node.visible = true
		else:
			node.visible = false
	var name = data.ChestOrder[chest_order % len(data.ChestOrder)]
	chest_name.text = name
	chest_icon.Set(name)
	
func PlayWinAnim():
	if medal < data.MedalsPerRank:
		anim.play("win")
		yield(anim, "animation_finished")
		medal_add_anim.play("medal_add%d" % (medal+1))
		yield(medal_add_anim, "animation_finished")
	else:
		anim.play("rankup")
		yield(anim, "animation_finished")
	anim_finished = true

func PlayLoseAnim():
	if medal > 0:
		anim.play("lose")
		yield(anim, "animation_finished")
		medal_remove_anim.play("medal_remove%d" % (medal))
		yield(medal_remove_anim, "animation_finished")
	else:
		anim.play("rankdown")
		yield(anim, "animation_finished")
	anim_finished = true

func PlayDrawAnim():
	anim.play("draw")
	yield(anim, "animation_finished")
	anim_finished = true
