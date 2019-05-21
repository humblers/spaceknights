extends "res://game/ui/opening.gd"

func Play():
	blue_user_name.text = "New-Knight"
	blue_leader_name.SetText("ID_%s" % blue_leader.to_upper())
	blue_leader_desc.SetText("ID_LEADER_SKILL_%s" % blue_leader.to_upper())
	var path = loading_screen.GetCardIconPathInGame(blue_leader)
	blue_leader_icon.texture = loading_screen.LoadResource(path)
	blue_rank = 25
	blue_rank_num.text = str(blue_rank)
	blue_rank_icon.texture = loading_screen.LoadResource("res://atlas/lobby/contents.sprites/rank/rank_icon_%d.tres" % blue_rank)
	red_user_name.text = "Master-Knight"
	red_leader_name.SetText("ID_%s" % red_leader.to_upper())
	red_leader_desc.SetText("ID_LEADER_SKILL_%s" % red_leader.to_upper())
	path = loading_screen.GetCardIconPathInGame(red_leader)
	red_leader_icon.texture = loading_screen.LoadResource(path)
	red_rank = 0
	red_rank_num.text = str(red_rank)
	red_rank_icon.texture = loading_screen.LoadResource("res://atlas/lobby/contents.sprites/rank/rank_icon_%d.tres" % red_rank)
	anim.play("show")