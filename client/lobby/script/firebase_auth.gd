extends FirebaseAuth

const GOOGLE_PROVIDER_ID = "google.com"
const FACEBOOK_PROVIDER_ID = "facebook.com"

func _ready():
	initialize(config.GOOGLE_PLAYSERVICE_JSON)

func link_account(idp):
	var token
	match idp:
		GOOGLE_PROVIDER_ID:
			request_google_id_token()
			var res = yield(self, "on_request_google_id_token_complete")
			if res.auth_error != kAuthErrorNone:
				global_object.lobby.http_manager.handle_error(res.error_message)
				return
			token = res.google_id_token
			link_with_google_id_token(token)
		FACEBOOK_PROVIDER_ID:
			request_facebook_access_token()
			var res = yield(self, "on_request_facebook_access_token_complete")
			if res.auth_error != kAuthErrorNone:
				global_object.lobby.http_manager.handle_error(res.error_message)
				return
			token = res.access_token
			link_with_facebook_access_token(token)
		_:
			global_object.lobby.http_manager.handle_error(idp)
			return
	var res = yield(self, "on_link_complete")
	match res.auth_error:
		kAuthErrorNone, kAuthErrorProviderAlreadyLinked:
			return
		kAuthErrorCredentialAlreadyInUse:
			var modal = global_object.lobby.hud.confirm_modal
			modal.PopUp("ID_MODAL_CONFIRM_CHANGE_ACCOUNT")
			var ok = yield(modal, "modal_confirmed")
			if ok:
				change_account(idp, token)

func change_account(idp, token):
	match idp:
		GOOGLE_PROVIDER_ID:
			sign_in_with_google_id_token(token)
		FACEBOOK_PROVIDER_ID:
			sign_in_with_facebook_access_token(token)
		_:
			global_object.lobby.http_manager.handle_error(idp)
			return
	var res = yield(self, "on_sign_in_complete")
	if res.auth_error != kAuthErrorNone:
		global_object.lobby.http_manager.handle_error(res.error_message)
		return
	global_object.lobby = null
	loading_screen.goto_scene("res://company_logo/company_logo.tscn")