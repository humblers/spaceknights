extends "res://lobby/page/page.gd"

export(NodePath) onready var light = get_node(light)

export(NodePath) onready var knight_resources = get_node(knight_resources)
export(NodePath) onready var knight_left = get_node(knight_left)
export(NodePath) onready var knight_center = get_node(knight_center)
export(NodePath) onready var knight_right = get_node(knight_right)

export(NodePath) onready var match_btn = get_node(match_btn)

export(NodePath) onready var pid = get_node(pid)
export(NodePath) onready var star = get_node(star)

func _ready():
	match_btn.connect("button_up", self, "match_request")

func invalidate():
	pid.text = user.PlatformId
	star.text = "%d" % user.Solo.Star
	var knights = user.Decks[user.DeckSelected].Knights
	for i in len(user.KNIGHT_SIDES):
		var knight = knights[i]
		var deck = get("knight_%s" % user.KNIGHT_SIDES[i])
		for child in deck.get_children():
			child.queue_free()
		var node = knight_resources.get_resource(knight).instance()
		recursive_light_masking(node, light.range_item_cull_mask)
		deck.add_child(node)

func recursive_light_masking(node, mask):
	if node.get("light_mask") != null:
		node.light_mask = mask
	if node.get_child_count() > 0:
		for child in node.get_children():
			recursive_light_masking(child, mask)

func match_request():
	var req = lobby.http_manager.new_request(HTTPClient.METHOD_POST, "/match/request")
	lobby.hud.requesting_dialog.pop(req)
	var response = yield(req, "response")
	if not response[0]:
		lobby.http_manager.handle_error(response[1].ErrMessage)
		return
	var cfg = response[1].Config
	var addr = cfg.Address.split(":")
	tcp.Connect(addr[0], int(addr[1]))
	yield(tcp, "connected")
	tcp.Send({"Id": user.Id, "Token": user.Id})
	tcp.Send({"GameId": cfg.Id})
	var param = {"connected": true, "cfg": cfg}
	loading_screen.goto_scene("res://game/game.tscn", param)

func _on_TempButton_button_down():
	$TempPopup1.show()

func _on_TempButton_button_up():
	$TempPopup1.hide()

func _on_Box0_button_down():
	$TempPopup3.show()

func _on_Box0_button_up():
	$TempPopup3.hide()

func _on_Box2_button_down():
	$TempPopup3.show()

func _on_Box2_button_up():
	$TempPopup3.hide()

func _on_Box5_button_down():
	$TempPopup3.show()

func _on_Box5_button_up():
	$TempPopup3.hide()

func _on_Box6_button_down():
	$TempPopup3.show()

func _on_Box6_button_up():
	$TempPopup3.hide()

func _on_Box7_button_down():
	$TempPopup3.show()

func _on_Box7_button_up():
	$TempPopup3.hide()

func _on_Box1_button_down():
	$TempPopup2.show()

func _on_Box1_button_up():
	$TempPopup2.hide()

func _on_Box3_button_down():
	$TempPopup2.show()

func _on_Box3_button_up():
	$TempPopup2.hide()

func _on_Box4_button_down():
	$TempPopup2.show()

func _on_Box4_button_up():
	$TempPopup2.hide()

func _on_MedalBox_button_down():
	$TempPopup2.show()

func _on_MedalBox_button_up():
	$TempPopup2.hide()

func _on_Option_button_down():
	$TempPopup4.show()

func _on_Option_button_up():
	$TempPopup4.hide()
