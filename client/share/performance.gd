extends CanvasLayer

func _process(delta):
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var ms = 1000 / fps
	$FPS.text = "FPS: %d (%d ms)" % [int(fps), int(ms)]