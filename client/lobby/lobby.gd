extends Node

const PAGES = ["Battle", "Card", "Explore", "Shop", "Social"]

onready var firebase_auth_manager = $Managers/FirebaseAuth
onready var resource_manager = $Managers/Resources

func _ready():
	event.connect("InvalidateLobby", self, "invalidate")
	login()

func load_data():
	for path in ["cards", "units", "Chests", "ChestOrder"]:
		var response = yield(lobby_request.New("/data/%s" % path.to_lower()), "Completed")
		if not response[0]:
			handleErrorInLoadStep(response[1].ErrMessage)
			return
		data.set(path, static_func.cast_float_to_int(parse_json(response[1]["Data"])))
	for path in ["upgrade"]:
		var response = yield(lobby_request.New("/data/%s" % path.to_lower()), "Completed")
		if not response[0]:
			handleErrorInLoadStep(response[1].ErrMessage)
			return
		var d = static_func.cast_float_to_int(parse_json(response[1]["Data"]))
		data.Upgrade.Set(d)
	invalidate()
	connect_to_notifier()

func connect_to_notifier():
	if not notifier_client.client_connected:
		notifier_client.Connect(config.get("NOTIFIER_HOST"), config.get("NOTIFIER_PORT"))
		yield(notifier_client, "connected")
		notifier_client.Send({"Id": user.Id, "Token": user.Id})
	event.emit_signal("LoadSceneCompleted")
	event.emit_signal("LobbyInitialized")

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
	var response = yield(lobby_request.New("/auth/login", params), "Completed")
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

func invalidate():
	event.emit_signal("InvalidateHUD")
	event.emit_signal("InvalidatePageBattle")
	event.emit_signal("InvalidatePageCard")

func handleErrorInLoadStep(message):
	event.emit_signal("RequestPopup", event.PopupModalMessage, [message])
	event.emit_signal("LoadSceneCompleted")