extends "res://lobby/page/page.gd"

func _ready():
	$Mid/NinePatchRect/Match.connect("pressed", self, "match_request")
	$Boxes/GridContainer/Box0.connect("button_down", self, "show_boxes_second_line")

func invalidate():
	$Profile/EmblemFrame/VBoxContainer/PID.text = user.PlatformId
	$Profile/RankFrame/Star.text = "%d" % user.Solo.Star

func match_request():
	var req = http.new_request(HTTPClient.METHOD_POST, "/match/request")
	$Requesting.pop(req)
	var resp = yield(req, "response")
	var cfg = resp[1].Config
	tcp.Connect(resp[1].Address, 9999)
	yield(tcp, "connected")
	tcp.Send({"Id": user.Id, "Token": user.Id})
	tcp.Send({"GameId": cfg.Id})
	var param = {"connected": true, "cfg": cfg}
	loading_screen.goto_scene("res://game/game.tscn", param)

func show_boxes_second_line():
	$Boxes/AnimationPlayer.play("show_second")