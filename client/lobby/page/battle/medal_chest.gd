extends TextureButton

export(NodePath) onready var lobby = get_node(lobby)
export(NodePath) onready var progress = get_node(progress)
export(NodePath) onready var progress_text = get_node(progress_text)

func _ready():
	connect("button_up", self, "open")
	
func Set(medals):
	progress.value = medals
	progress.max_value = data.RequiredMedalsForMedalChest
#	progress_text.text = "%d/%d" % [progress.value, progress.max_value]

func open():
	if progress.value < progress.max_value:
		return
	var params = {"Name": "Medal"}
	var req = lobby_request.New("/chest/open", params)
	var response = yield(req, "Completed")
	if not response[0]:
		lobby.HandleError(response[1].ErrMessage)
		return
	var gold = response[1].Gold
	var cash = response[1].Cash
	var cards = response[1].Cards
	
	# apply and invalidate ui
	user.Galacticoin += gold
	user.Dimensium += cash
	for name in cards:
		var count = cards[name]
		if not user.Cards.has(name):
			user.Cards[name] = {"Level": 0, "Holding": 0}
		user.Cards[name].Holding += count
	user.MedalChest = 0
	lobby.Invalidate()
	lobby.hud.chestopen_dialog.PopUp("Medal", gold, cash, cards)
