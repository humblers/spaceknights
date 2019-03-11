extends Node

const PAGES = ["Battle", "Card", "Explore", "Shop", "Social"]

export(NodePath) onready var hud = get_node(hud)
export(NodePath) onready var input_manager = get_node(input_manager)
export(NodePath) onready var http_manager = get_node(http_manager)
export(NodePath) onready var firebase_auth_manager = get_node(firebase_auth_manager)
export(NodePath) onready var resource_manager = get_node(resource_manager)
export(NodePath) onready var page_battle = get_node(page_battle)
export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var page_explore = get_node(page_explore)
export(NodePath) onready var page_shop = get_node(page_shop)
export(NodePath) onready var page_social = get_node(page_social)

func _ready():
	global_object.lobby = self
	add_user_signal("load_completed")
	input_manager.move_to_page(PAGES[0])
	requestNewChest()
	login()

func load_data():
	for path in ["cards", "units", "Chests", "ChestOrder"]:
		var response = yield(http_manager.RequestToLobby("/data/%s" % path.to_lower()), "receive_response")
		if not response[0]:
			handleErrorInLoadStep(response[1].ErrMessage)
			return
		data.set(path, static_func.cast_float_to_int(parse_json(response[1]["Data"])))
	for path in ["upgrade"]:
		var response = yield(http_manager.RequestToLobby("/data/%s" % path.to_lower()), "receive_response")
		if not response[0]:
			handleErrorInLoadStep(response[1].ErrMessage)
			return
		var d = static_func.cast_float_to_int(parse_json(response[1]["Data"]))
		data.set(path.capitalize(), resource_manager.scripts.get_resource(path).new(d))
	Invalidate()
	page_battle.PlayAppearAni()
	emit_signal("load_completed")

func login():
	# for desktop
	firebase_auth_manager.sign_in_with_email_and_password_if_exists()
	yield(firebase_auth_manager, "on_sign_in_complete")

	var params = {}
	if firebase_auth_manager.has_user():
		firebase_auth_manager.retrieve_token()
		var res = yield(firebase_auth_manager, "on_retrieve_token_complete")
		if res.auth_error != firebase_auth_manager.kAuthErrorNone:
			handleErrorInLoadStep(res.error_message)
			return
		params["firebasetoken"] = res.token
	var response = yield(http_manager.RequestToLobby("/auth/login", params), "receive_response")
	if not response[0]:
		handleErrorInLoadStep(response[1].ErrMessage)
		return
	if response[1].FirebaseToken != "":
		firebase_auth_manager.sign_in_with_custom_token(response[1].FirebaseToken)
		var res = yield(firebase_auth_manager, "on_sign_in_complete")
		if res.auth_error != firebase_auth_manager.kAuthErrorNone:
			handleErrorInLoadStep(res.error_message)
			return
	user.HumblerToken = response[1].HumblerToken
	user.IssuedAt = response[1].IssuedAt
	user.Id = response[1].UID
	for k in response[1].User.keys():
		user.set(k, response[1].User[k])
	load_data()

func Invalidate():
	hud.invalidate()
	page_battle.invalidate()
	page_card.Invalidate()

func handleErrorInLoadStep(message):
	HandleError(message, true)
	emit_signal("load_completed")

func HandleError(message, back_to_company_logo = true):
	hud.message_modal.PopUp(message)
	if not back_to_company_logo:
		return
	yield(hud.message_modal, "popup_hide")
	loading_screen.goto_scene("res://company_logo/company_logo.tscn")

func requestNewChest():
	if not user.request_new_chest:
		return
	user.request_new_chest = false
	var req = http_manager.RequestToLobby("/chest/new", { "Name": "Battle", "Rank": user.Rank })
	var response = yield(req, "receive_response")
	if not response[0]:
		HandleError(response[1].ErrMessage)
		return