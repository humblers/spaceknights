extends Popup

onready var link_google = $VBoxContainer/Buttons/Google/Button

func Invalidate():
	var firebase = global_object.lobby.firebase_auth_manager
	if not link_google.is_connected("button_up", firebase, "current_user_link_with_google"):
		link_google.connect("button_up", firebase, "current_user_link_with_google")
	var providers = firebase.get_provider_ids()
	var google_linked = providers.has("google.com")
	print("providers: ", providers, ", googlelinked: ", google_linked)
	link_google.disabled = google_linked
	link_google.get_node("Description").text = "LINKED" if google_linked else "CONNECTED"