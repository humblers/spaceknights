extends Popup

onready var link_google = $VBoxContainer/Buttons/Google/Button
onready var link_google_status = $VBoxContainer/Buttons/Google/Button/Description
onready var link_facebook = $VBoxContainer/Buttons/Facebook/Button
onready var link_facebook_status = $VBoxContainer/Buttons/Facebook/Button/Description
onready var link_email = $VBoxContainer/Buttons/Email/Button
onready var link_email_status = $VBoxContainer/Buttons/Email/Button/Description

onready var uid = $VBoxContainer/HBoxContainer/UID

onready var language_button = $VBoxContainer/Buttons/Language/Button
onready var current_language = $VBoxContainer/Buttons/Language/Button/Description

onready var intro_button = $VBoxContainer/Buttons2/Intro/Button

func _ready():
	$Close.connect("button_up", self, "hide")
	language_button.connect("button_up", self, "select_language")
	intro_button.connect("button_up", self, "playIntro")
	if not OS.get_name() in ["Android", "iOS"]:
		$VBoxContainer/Buttons/Email/Label.visible = true
		link_email.visible = true
		link_email.connect("button_up", self, "email_link")

func PopUp():
	Invalidate()
	popup()

func Invalidate():
	var firebase = get_tree().current_scene.firebase_auth_manager
	if not link_google.is_connected("button_up", firebase, "link_account"):
		link_google.connect("button_up", firebase, "link_account", [firebase.GOOGLE_PROVIDER_ID, self])
	if not link_facebook.is_connected("button_up", firebase, "link_account"):
		link_facebook.connect("button_up", firebase, "link_account", [firebase.FACEBOOK_PROVIDER_ID, self])
	var providers = firebase.get_provider_ids()
	var google_linked = providers.has(firebase.GOOGLE_PROVIDER_ID)
	link_google.disabled = google_linked
	link_google_status.text = "ID_SETTING_LINKED" if google_linked else "ID_SETTING_LINK"
	var facebook_linked = providers.has(firebase.FACEBOOK_PROVIDER_ID)
	link_facebook.disabled = facebook_linked
	link_facebook_status = "ID_SETTING_LINKED" if facebook_linked else "ID_SETTNG_LINK"
	var email_linked = providers.has(firebase.EMAIL_PASSWORD_PROVIDER_ID)
	link_email.disabled = email_linked
	link_email_status = "ID_SETTING_LINKED" if email_linked else "ID_SETTNG_LINK"

	uid.text = "%s" % user.Id
	current_language.SetText("ID_SETTING_%s" % user.locale.to_upper())

func select_language():
	event.emit_signal("RequestPopup", event.PopupModalConfirm, ["ID_MODAL_CONFIRM_CHANGE_LANGUAGE"])
	var ok = yield(event, "ModalConfirmed")
	if not ok:
		return
	user.locale = "en" if user.locale != "en" else "ko"
	var config = ConfigFile.new()
	var err = config.load(user.CONFIG_FILE_NAME)
	if err != OK:
		print("config file load fail. file name: ", user.CONFIG_FILE_NAME, ", err code: ", err)
		assert(err in [ERR_FILE_NOT_FOUND, ERR_FILE_CANT_OPEN, ERR_FILE_CANT_READ, ERR_CANT_OPEN])
	config.set_value("locale", "language", user.locale)
	config.save(user.CONFIG_FILE_NAME)
	loading_screen.GoToScene("res://company_logo/company_logo.tscn")

func email_link():
	$PopupEmail.popup_centered()
	yield($PopupEmail/VBoxContainer/TextureButton, "button_up")
	$PopupEmail.hide()
	var email = $PopupEmail/VBoxContainer/HBoxContainer/TextEditEmail.text
	var password = $PopupEmail/VBoxContainer/HBoxContainer2/TextEditPassword.text
	var firebase = get_tree().current_scene.firebase_auth_manager
	firebase.link_account(firebase.EMAIL_PASSWORD_PROVIDER_ID, self, email, password)

func playIntro():
	loading_screen.GoToScene("res://intro/intro.tscn", [], {"next_scene": "res://lobby/lobby.tscn"})

func modalConfirm():
	return "ok"
	
