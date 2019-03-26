extends Control

onready var blue_leader_name = $Deckopen/Blue/ControlB/Control/UnitnameB
onready var blue_leader_desc = $Deckopen/Blue/ControlB/Control/DescriptB
onready var blue_leader_icon = $Deckopen/Blue/ControlB/KnightBG/KnightB
onready var red_leader_name = $Deckopen/Red/ControlR/Control/UnitnameB
onready var red_leader_desc = $Deckopen/Red/ControlR/Control/DescriptB
onready var red_leader_icon = $Deckopen/Red/ControlR/KnightBG/KnightB
onready var anim = $AnimationPlayer

func Play(blue_leader, red_leader, icon_resource):
	blue_leader_name.SetText("ID_%s" % blue_leader.to_upper())
	blue_leader_desc.SetText("ID_LEADER_SKILL_%s" % blue_leader)
	blue_leader_icon.texture = icon_resource.get_resource(blue_leader)
	red_leader_name.SetText("ID_%s" % red_leader.to_upper())
	red_leader_desc.SetText("ID_LEADER_SKILL_%s" % red_leader)
	red_leader_icon.texture = icon_resource.get_resource(red_leader)
	anim.play("show")