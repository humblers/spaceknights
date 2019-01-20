extends TextureButton

export(NodePath) onready var label = get_node(label)
export(NodePath) onready var lobby = get_node(lobby)

var last_acquired_time = 0

func Set(time):
	last_acquired_time = time
	invalidate()

func time_left():
	return last_acquired_time + data.Chests["Free"].Duration - OS.get_unix_time()

func _ready():
	connect("button_up", self, "open")

func _process(delta):
	invalidate()
	
func invalidate():
	var time_left = time_left()
	if time_left > 0:
		label.text = static_func.get_time_left_string(time_left)
	else:
		label.text = "Open"

func open():
	if time_left() > 0:
		return
	var params = {"Name": "Free"}
	var req = lobby.http_manager.new_request(
			HTTPClient.METHOD_POST, "/chest/open",
			params)
	var response = yield(req, "response")
	if not response[0]:
		lobby.http_manager.handle_error(response[1].ErrMessage)
		return
	var gold = response[1].Gold
	var cash = response[1].Cash
	var cards = response[1].Cards
	var opened_at = response[1].OpenedAt
	
	# apply and invalidate ui
	user.Galacticoin += gold
	user.Dimensium += cash
	for name in cards:
		var count = cards[name]
		if not user.Cards.has(name):
			user.Cards[name] = {"Level": 0, "Holding": 0}
		user.Cards[name].Name = name	# TODO: delete this
		user.Cards[name].Holding += count
	user.FreeChest = opened_at
	lobby.Invalidate()
	lobby.hud.chestopen_dialog.PopUp("Free", gold, cash, cards)
	