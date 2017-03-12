extends Area


func _on_Area_body_exit( body ):
	if body.is_in_group("unfreed_nodes"):
		return
	body.queue_free()
