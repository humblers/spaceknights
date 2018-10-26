extends Control

var param = null
var thread = null
onready var progress = $ProgressBar

func goto_scene(path, param = null):
	get_tree().current_scene.queue_free()
	get_tree().current_scene = self
	progress.value = 0
	self.param = param
	thread = Thread.new()
	thread.start(self, "_load_scene", path)
	
func _load_scene(path):
	var loader = ResourceLoader.load_interactive(path)
	assert(loader != null)
	var total = loader.get_stage_count()
	progress.call_deferred("set_max", total)
	
	var res = null
	while(true):
		progress.call_deferred("set_value", loader.get_stage())
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			res = loader.get_resource()
			break
		elif err != OK:
			print("error loading %s" % path)
			break
	
	call_deferred("_load_done", res)

func _load_done(res):
	assert(res)
	progress.value = progress.max_value
	thread.wait_to_finish()
	var new_scene = res.instance()
	if param != null:
		for k in param:
			new_scene.set(k, param[k])
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene