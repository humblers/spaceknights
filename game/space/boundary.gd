extends Area

export var isLeft = true

func _on_LeftBoundary_body_enter( body ):
	if body.is_in_group("unfreed_nodes"):
		body.reached_left_edge()
		return
	body.queue_free()

func _on_RightBoundary_body_enter( body ):
	if body.is_in_group("unfreed_nodes"):
		body.reached_right_edge()
		return
	body.queue_free()
