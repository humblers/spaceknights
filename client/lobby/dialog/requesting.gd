extends Control

var elapsed
var time_out

func _ready():
	set_process(false)

func _process(delta):
	elapsed += delta
	$Elapsed.text = "%d" % elapsed
	if time_out > 0 and elapsed >= time_out:
		set_process(false)
		visible =false

func pop(request, time_out=0):
	self.elapsed = 0
	self.time_out = time_out
	show_modal()
	visible = true
	set_process(true)
	yield(request, "response")
	set_process(false)
	visible = false