extends Control

var use_thread = false
var path = null
var param = null
var thread = null
onready var progress = $ProgressBar

func _ready():
	visible = false
	
func goto_scene(path, param = null):
	self.visible = true
	get_tree().current_scene.queue_free()
	get_tree().current_scene = self
	progress.value = 0
	self.param = param
	if use_thread:
		thread = Thread.new()
		thread.start(self, "_load_scene", path)
	else:
		_load_scene_no_thread(path)
	
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

func _load_scene_no_thread(path):
	var loader = ResourceLoader.load_interactive(path)
	assert(loader != null)
	progress.max_value = loader.get_stage_count()
	
	while(true):
		progress.value = loader.get_stage()
		yield(get_tree(), "idle_frame")			# show progress
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var res = loader.get_resource()
			assert(res)
			progress.value = progress.max_value
			var new_scene = res.instance()
			if param != null:
				for k in param:
					new_scene.set(k, param[k])
			get_tree().root.add_child(new_scene)
			get_tree().current_scene = new_scene
			break
		elif err != OK:
			print("error loading %s" % path)
			break
	self.visible = false
