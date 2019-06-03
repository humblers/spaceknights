extends Control

const NUM_COLUMN = 4

onready var popup = $Popup
onready var upper_pos = $UpperSlotPosition.position
onready var lower_pos = $LowerSlotPosition.position

onready var chest_icon = $Popup/Chest/Icon
onready var chest_name = $Popup/Panel/Title/ChestName
onready var arena_name = $Popup/Panel/Contents/Arena

onready var coin_amount = $Popup/Panel/Contents/Coin/Amount
onready var card_amount = $Popup/Panel/Contents/Card/Amount
onready var rare_amount = $Popup/Panel/Contents/Guaranteed/Rare
onready var epic_amount = $Popup/Panel/Contents/Guaranteed/Epic
onready var legendary_amount = $Popup/Panel/Contents/Guaranteed/Legendary

onready var remain_time = $Popup/Panel/Contents/TimeLeft
onready var open_button = $Popup/Panel/Contents/Open
onready var instant_open_button = $Popup/Panel/Contents/InstantOpen
onready var instant_open_cost = $Popup/Panel/Contents/InstantOpen/HBoxContainer/Cost

onready var arrow_0 = $Popup/Panel/Arrow0
onready var arrow_1 = $Popup/Panel/Arrow1
onready var arrow_2 = $Popup/Panel/Arrow2
onready var arrow_3 = $Popup/Panel/Arrow3

var chest
var kind
var slot

func _ready():
	open_button.connect("button_up", self, "open")
	instant_open_button.connect("button_up", self, "open", [true])

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		if not popup.get_global_rect().has_point(event.global_position):
			visible = false
	
func open(use_cash=false):
	var params = {"Kind": kind, "Name": chest.Name, "Slot": slot, "UseCash": use_cash}
	var req = lobby_request.New("/chest/open", params)
	var response = yield(req, "Completed")
	if not response[0]:
		event.emit_signal("RequestPopup", event.PopupModalMessage, [response[1].ErrMessage])
		return
	var gold = response[1].Gold
	var cards = response[1].Cards
	var used_cash = response[1].UsedCash

	# apply and invalidate ui
	user.Dimensium -= used_cash
	if kind == "Battle":
		user.BattleChestSlots[slot] = null
	elif kind == "Feeble":
		user.FeebleChestSlots[slot] = null
	user.Galacticoin += gold
	for name in cards:
		var count = cards[name]
		if not user.Cards.has(name):
			user.Cards[name] = {"Level": 0, "Holding": 0}
		user.Cards[name].Holding += count
	event.emit_signal("InvalidateLobby")

	# for test
	#get_tree().current_scene.hud.chestopen_dialog.PopUp(chest.Name, gold, 0, cards)
	var cash = response[1].Cash
	user.Dimensium += cash
	event.emit_signal("RequestDialog", event.DialogChestOpen, [chest.Name, gold, cash, cards])

	visible = false

func PopUp(chest, kind, slot):
	self.chest = chest
	self.kind = kind
	self.slot = slot
	var arena = data.ArenaFromRank(chest.AcquiredRank)
	var chest_data = data.Chests[chest.Name]
	var card_count = chest_data.NumCards[arena]
	var coin_min = card_count * chest_data.MinGoldPerCard
	var coin_max = card_count * chest_data.MaxGoldPerCard
	var guaranteed = chest_data.Guaranteed
	var rare_count = guaranteed.Rare[arena] if guaranteed.has("Rare") else 0
	var epic_count = guaranteed.Epic[arena] if guaranteed.has("Epic") else 0
	var legendary_count = guaranteed.Legendary[arena] if guaranteed.has("Legendary") else 0

	chest_icon.Set(chest.Name)
	chest_name.text = "%s CHEST" % chest.Name.to_upper()
	arena_name.text = data.ArenaNames[arena]
	
	coin_amount.text = "%d-%d" % [coin_min, coin_max]
	card_amount.text = "x %d" % card_count
	rare_amount.text = "x %d" % rare_count
	epic_amount.text = "x %d" % epic_count
	legendary_amount.text = "x %d" % legendary_count
	rare_amount.visible = rare_count > 0
	epic_amount.visible = epic_count > 0
	legendary_amount.visible = legendary_count > 0

	for i in NUM_COLUMN:
		get("arrow_%d" % i).visible = (i == slot % NUM_COLUMN)

	visible = true
	popup.rect_position.y = upper_pos.y if slot < NUM_COLUMN else lower_pos.y

func _process(delta):
	if not visible:
		return
	var time_left = time_left()
	if time_left > 0:
		open_button.visible = false
		instant_open_button.visible = true
		remain_time.visible = true
		remain_time.text = static_func.get_time_left_string(time_left)
		instant_open_cost.text = str(data.RequiredCashForTime(time_left))
	else:
		open_button.visible = true
		instant_open_button.visible = false
		remain_time.visible = false

func time_left():
	assert(chest)
	return chest.AcquiredAt + data.Chests[chest.Name].Duration - OS.get_unix_time()
