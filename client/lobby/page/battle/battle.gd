extends "res://lobby/page/page.gd"

export(NodePath) onready var light = get_node(light)

export(NodePath) onready var knight_resources = get_node(knight_resources)
export(NodePath) onready var knight_left = get_node(knight_left)
export(NodePath) onready var knight_center = get_node(knight_center)
export(NodePath) onready var knight_right = get_node(knight_right)

export(NodePath) onready var match_btn = get_node(match_btn)
export(NodePath) onready var config_btn = get_node(config_btn)

export(NodePath) onready var user_name = get_node(user_name)
export(NodePath) onready var rank = get_node(rank)

export(NodePath) onready var free_chest = get_node(free_chest)
export(NodePath) onready var medal_chest = get_node(medal_chest)
export(NodePath) onready var chest_0 = get_node(chest_0)
export(NodePath) onready var chest_1 = get_node(chest_1)
export(NodePath) onready var chest_2 = get_node(chest_2)
export(NodePath) onready var chest_3 = get_node(chest_3)
export(NodePath) onready var chest_4 = get_node(chest_4)
export(NodePath) onready var chest_5 = get_node(chest_5)
export(NodePath) onready var chest_6 = get_node(chest_6)
export(NodePath) onready var chest_7 = get_node(chest_7)

func _ready():
	match_btn.connect("button_up", self, "match_request")
	config_btn.connect("button_up", self, "show_config")

func Invalidate():
	# temporary set uid
	user_name.text = user.Id
	rank.text = "%d" % user.Rank
	for card in user.DeckSlots[user.DeckSelected]:
		card = data.NewCard(card)
		if card.Type == data.SquireCard:
			continue
		var deck = get("knight_%s" % card.Side.to_lower())
		for child in deck.get_children():
			child.queue_free()
		var node = knight_resources.get_resource(card.Name).instance()
		recursive_light_masking(node, light.range_item_cull_mask)
		deck.add_child(node)
	
	# set chests
	free_chest.Set(user.FreeChest)
	medal_chest.Set(user.MedalChest)
	for i in len(user.BattleChestSlots):
		var chest = user.BattleChestSlots[i]
		var node = get("chest_%d" % i)
		node.Set(chest)
	
func recursive_light_masking(node, mask):
	if node.get("light_mask") != null:
		node.light_mask = mask
	if node.get_child_count() > 0:
		for child in node.get_children():
			recursive_light_masking(child, mask)

func match_request():
	var req = lobby_request.New("/match/request")
	lobby.hud.requesting_dialog.pop(req)
	var response = yield(req, "Completed")
	if not response[0]:
		lobby.HandleError(response[1].ErrMessage)
		return
	var cfg = response[1].Config
	var non_preload_paths = []
	for player in cfg.Players:
		for card in player.Deck:
			non_preload_paths += loading_screen.GetReqResourcePathsInGame(data.NewCard(card))
	var addr = cfg.Address.split(":")
	tcp.Connect(addr[0], int(addr[1]))
	yield(tcp, "connected")
	tcp.Send({"Id": user.Id, "Token": user.Id})
	tcp.Send({"GameId": cfg.Id})
	var param = {"connected": true, "cfg": cfg}
	loading_screen.GoToScene("res://game/game.tscn", non_preload_paths, param)

func show_config():
	var setting = lobby.hud.get_node("PopupSetting")
	setting.Invalidate()
	setting.popup()

func PlayAppearAni():
	$Background/Mothership/AppearAni.play("appear")
