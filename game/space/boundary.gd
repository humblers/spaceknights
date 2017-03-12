extends Area


func _on_Area_body_exit( body ):
	body.queue_free()
