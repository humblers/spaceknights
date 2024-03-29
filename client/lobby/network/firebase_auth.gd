extends FirebaseAuth

const GOOGLE_PROVIDER_ID = "google.com"
const FACEBOOK_PROVIDER_ID = "facebook.com"
const EMAIL_PASSWORD_PROVIDER_ID = "password"

func _ready():
	initialize(config.GOOGLE_PLAYSERVICE_JSON)

func link_account(idp, setting_popup, arg1 = null, arg2 = null):
	var token
	match idp:
		GOOGLE_PROVIDER_ID:
			request_google_id_token()
			var res = yield(self, "on_request_google_id_token_complete")
			if res.auth_error != kAuthErrorNone:
				event.emit_signal("RequestPopup", event.PopupModalMessage, [res.error_message])
				return
			token = res.google_id_token
			link_with_google_id_token(token)
		FACEBOOK_PROVIDER_ID:
			request_facebook_access_token()
			var res = yield(self, "on_request_facebook_access_token_complete")
			if res.auth_error != kAuthErrorNone:
				event.emit_signal("RequestPopup", event.PopupModalMessage, [res.error_message])
				return
			token = res.access_token
			link_with_facebook_access_token(token)
		EMAIL_PASSWORD_PROVIDER_ID:
			# arg1 == email, arg2 == password
			assert(typeof(arg1) == TYPE_STRING)
			assert(typeof(arg2) == TYPE_STRING)
			link_with_email_and_password(arg1, arg2)
		_:
			event.emit_signal("RequestPopup", event.PopupModalMessage, [idp])
			return
	var res = yield(self, "on_link_complete")
	match res.auth_error:
		kAuthErrorNone, kAuthErrorProviderAlreadyLinked:
			setting_popup.Invalidate()
			if idp == EMAIL_PASSWORD_PROVIDER_ID:
				save_email_password(arg1, arg2)
		kAuthErrorCredentialAlreadyInUse, kAuthErrorEmailAlreadyInUse:
			event.emit_signal("RequestPopup", event.PopupModalConfirm, ["ID_MODAL_CONFIRM_CHANGE_ACCOUNT"])
			var ok = yield(event, "ModalConfirmed")
			if ok:
				change_account(idp, token, arg1, arg2)
		_:
			event.emit_signal("RequestPopup", event.PopupModalMessage, [res.error_message])

func change_account(idp, token, arg1 = null, arg2 = null):
	match idp:
		GOOGLE_PROVIDER_ID:
			sign_in_with_google_id_token(token)
		FACEBOOK_PROVIDER_ID:
			sign_in_with_facebook_access_token(token)
		EMAIL_PASSWORD_PROVIDER_ID:
			sign_in_with_email_and_password(arg1, arg2)
		_:
			event.emit_signal("RequestPopup", event.PopupModalMessage, [idp])
			return
	var res = yield(self, "on_sign_in_complete")
	if res.auth_error != kAuthErrorNone:
		event.emit_signal("RequestPopup", event.PopupModalMessage, [res.error_message])
		return
	if idp == EMAIL_PASSWORD_PROVIDER_ID:
		save_email_password(arg1, arg2)
	loading_screen.GoToScene("res://company_logo/company_logo.tscn")

func save_email_password(email, password):
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
		assert(err in [ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN])
	config.set_value("desktop_auth", "email", email)
	config.set_value("desktop_auth", "password", password)
	config.save(user.CONFIG_FILE_NAME)

func sign_in_with_email_and_password_if_exists():
	var config = ConfigFile.new()
	if config.load(user.CONFIG_FILE_NAME) != OK\
			or not config.has_section_key("desktop_auth", "email")\
			or not config.has_section_key("desktop_auth", "password"):
		call_deferred("emit_signal", "on_sign_in_complete", {"auth_error": kAuthErrorFailure})
		return
	sign_in_with_email_and_password(config.get_value("desktop_auth", "email"), config.get_value("desktop_auth", "password"))