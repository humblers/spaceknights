extends FirebaseAuth

func _ready():
	var f = File.new()
	f.open("res://google-services.json", File.READ)
	var config = f.get_as_text()
	f.close()
	initialize(config)

func current_user_link_with_google():
	request_google_id_token()
	var res = yield(self, "on_request_google_id_token_complete")
	if res.auth_error != kAuthErrorNone:
		global_object.lobby.http_manager.handle_error(res.error_message)
		return false
	var token = res.google_id_token
	link_with_google_id_token(token)
	res = yield(self, "on_link_complete")
	match res.auth_error:
		kAuthErrorNone, kAuthErrorProviderAlreadyLinked:
			return true
		kAuthErrorCredentialAlreadyInUse:
			var modal = global_object.lobby.hud.get_node("ModalConfirm")
			modal.PopUp("ID_MODAL_CONFIRM_CHANGE_ACCOUNT")
			var ok = yield(modal, "modal_confirmed")
			if ok:
				change_account_by_google_sign_in(token)
	return false

func change_account_by_google_sign_in(token):
	sign_in_with_google_id_token(token)
	var res = yield(self, "on_sign_in_complete")
	if res.auth_error != kAuthErrorNone:
		global_object.lobby.http_manager.handle_error(res.error_message)
		return
	global_object.lobby = null
	loading_screen.goto_scene("res://company_logo/company_logo.tscn")