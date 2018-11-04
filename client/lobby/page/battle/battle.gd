extends "res://lobby/page/page.gd"

var lobby

onready var decks = [
	$CenterTop/Mothership/Nodes/Deck/Center/Position/Unit,
	$CenterTop/Mothership/Nodes/Deck/Left/Position/Unit,
	$CenterTop/Mothership/Nodes/Deck/Right/Position/Unit,
]

func _ready():
	$Mid/NinePatchRect/Match.connect("pressed", self, "match_request")
	$Boxes/GridContainer/Box0.connect("button_down", self, "show_boxes_second_line")

func invalidate():
	$Profile/EmblemFrame/VBoxContainer/PID.text = user.PlatformId
	$Profile/RankFrame/Star.text = "%d" % user.Solo.Star
	var knights = user.Decks[user.DeckSelected].Knights
	for i in len(decks):
		var knight = knights[i]
		var deck = decks[i]
		for child in deck.get_children():
			child.queue_free()
		var node = $Knights.get_resource(knight).instance()
		recursive_light_masking(node, $CenterTop/Light2D.range_item_cull_mask)
		deck.add_child(node)

func recursive_light_masking(node, mask):
	if node.get("light_mask") != null:
		node.light_mask = mask
	if node.get_child_count() > 0:
		for child in node.get_children():
			recursive_light_masking(child, mask)

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