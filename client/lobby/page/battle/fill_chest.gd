extends TextureButton

func _ready():
	self.connect("button_up", self, "requestNewChest")

func requestNewChest():
	var req = lobby_request.New("/edit/chest/fill", { "Rank": user.Rank })
	var response = yield(req, "Completed")
	if not response[0]:
		get_tree().current_scene.HandleError(response[1].ErrMessage)
		return
	user.BattleChestSlots = response[1].BattleChests
	user.MedalChest = response[1].MedalChest
	get_tree().current_scene.Invalidate()