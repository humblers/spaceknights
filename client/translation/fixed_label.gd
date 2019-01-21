extends Label

func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		static_func.set_text(self, self.text)