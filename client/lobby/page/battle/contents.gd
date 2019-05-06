extends "res://lobby/page/scroller.gd"

export(NodePath) onready var match_btn = get_node(match_btn)
export(NodePath) onready var config_btn = get_node(config_btn)

export(NodePath) onready var user_name = get_node(user_name)
export(NodePath) onready var rank = get_node(rank)
export(NodePath) onready var rank_icon = get_node(rank_icon)

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
	event.connect("InvalidatePageBattle", self, "invalidate")
	match_btn.connect("button_up", self, "match_request")
	config_btn.connect("button_up", self, "show_config")

func invalidate():
	# temporary set uid
	user_name.text = "Imperial-Knight-%03d" % int(user.Id)
	rank.text = "%d" % user.Rank
	rank_icon.texture = loading_screen.LoadResource("res://atlas/lobby/contents.sprites/rank/rank_icon_%d.tres" % user.Rank)
	
	# set chests
	free_chest.Set(user.FreeChest)
	medal_chest.Set(user.MedalChest)
	for i in len(user.BattleChestSlots):
		var chest = user.BattleChestSlots[i]
		var node = get("chest_%d" % i)
		node.Set(chest)
	
func match_request():
	notifier_client.connect("game_created", self, "start_game", [], CONNECT_ONESHOT)
	var req = lobby_request.New("/match/request")
	var response = yield(req, "Completed")
	if not response[0]:
		event.emit_signal("RequestMessageModal", response[1].ErrMessage, false)
		return
	event.emit_signal("RequestDialog", event.DialogMatchwating, [])

func show_config():
	event.emit_signal("RequestPopup", event.PopupSetting, [])

func start_game(cfg):
	var non_preload_paths = []
	for player in cfg.Players:
		for card in player.Deck:
			non_preload_paths += loading_screen.GetReqResourcePathsInGame(data.NewCard(card))
	var addr = cfg.Address.split(":")
	game_client.Connect(addr[0], int(addr[1]))
	yield(game_client, "connected")
	game_client.Send({"Id": user.Id, "Token": user.Id})
	game_client.Send({"GameId": cfg.Id})
	var param = {"connected": true, "cfg": cfg}
	loading_screen.GoToScene("res://game/game.tscn", non_preload_paths, param)