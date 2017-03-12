extends Area


func _on_Area_body_exit( body ):
	if body.get_name() == "player":
		return
	body.queue_free()
