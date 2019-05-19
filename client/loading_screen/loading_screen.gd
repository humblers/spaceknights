extends CanvasLayer

var loaded_resources = {}
var dest_path = ""
var param = null
var thread = null
onready var progress = $Control/ProgressBar
onready var visible_control = $Control

func _ready():
	visible_control.visible = false
	event.connect("LoadSceneCompleted", self, "hide")

func GoToScene(dest_path, nonpreload_paths = [], param = null):
	loaded_resources = {}
	visible_control.visible = true
	get_tree().current_scene.queue_free()
	get_tree().current_scene = self
	progress.value = 0
	self.dest_path = dest_path
	self.param = param
	nonpreload_paths.push_front(dest_path)
	thread = Thread.new()
	thread.start(self, "_load_scene", nonpreload_paths)

func LoadResource(path):
	if loaded_resources.has(path):
		return loaded_resources[path]
	if not ResourceLoader.has_cached(path):
		print("resource is not cached and not in loaded_resources: ", path)
	var res = ResourceLoader.load(path)
	loaded_resources[path] = res
	return res

func _load_scene(paths):
	var dest_scene = paths.pop_front()
	var loader = ResourceLoader.load_interactive(dest_scene)
	var total = loader.get_stage_count() + len(paths)
	progress.call_deferred("set_max", total)

	var loaded_resources = {}
	while(true):
		progress.call_deferred("set_value", loader.get_stage())
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			loaded_resources[dest_scene] = loader.get_resource()
			break
		elif err != OK:
			print("error loading %s" % dest_scene)
			break
	var cur = loader.get_stage()
	for i in range(len(paths)):
		var path = paths[i]
		loaded_resources[path] = ResourceLoader.load(path)
		progress.call_deferred("set_value", cur + i)
	call_deferred("_load_done", loaded_resources)

func _load_done(loaded_resources):
	assert(loaded_resources)
	thread.wait_to_finish()
	
	progress.value = progress.max_value
	
	# pause a while to show completed status(100%)
	yield(get_tree().create_timer(0.5), "timeout")
	
	# retain resource until current_scene freed
	self.loaded_resources = loaded_resources
	var new_scene = loaded_resources[dest_path].instance()

	# set parameters
	if param != null:
		for k in param:
			new_scene.set(k, param[k])

	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func hide():
	visible_control.visible = false

func GetStatIcon(layer, stat_key):
	var path = "res://atlas/lobby/%s.sprites/stat_icon/%s.tres"
	match stat_key:
		"damage", "attackdamage":
			path = path % [layer, "damage"]
		"damageduration", "duration":
			path = path % [layer, "damage_duration"]
		"areadamage":
			path = path % [layer, "area_damage"]
		"destroydamage":
			path = path % [layer, "death_damage"]
		"damagepersecond":
			path = path % [layer, "dps"]
		"areadps":
			path = path % [layer, "area_dps"]
		"attackinterval":
			path = path % [layer, "attack_speed"]
		"chargedattackdamage", "powerattackdamage", "absorbdamage":
			path = path % [layer, "skill_damage"]
		"damagetype":
			path = path % [layer, "attack_type"]
		"decaydamage":
			path = path % [layer, "lifetime"]
		"knightdamage":
			path = path % [layer, "knight_damage"]
		"attackrange":
			path = path % [layer, "attack_range"]
		"shield":
			path = path % [layer, "barrier"]
		"castduration":
			path = path % [layer, "cast_duration"]
		"freezeduration":
			path = path % [layer, "freeze_duration"]
		"count", "spawncount":
			path = path % [layer, "spawn_count"]
		"radius", "area": # this is temporary using. we must add area icon for showing skill area like a lancer, astra
			path = path % [layer, "radius"]
		"spawninterval":
			path = path % [layer, "spawn_speed"]
		_:
			path = path % [layer, stat_key]
	return LoadResource(path)

static func GetCardIconPathInGame(card_name):
	return "res://atlas/game/ui.sprites/icon/%s_small.tres" % [card_name]

static func GetUnitScenePath(unit):
	return "res://game/unit/%s/%s.tscn" % [unit, unit]

static func GetCardReadySoundPath(card):
	if card.Type != data.SquireCard:
		return "res://sound/sfx/ready/archers.wav"
	var path = "res://sound/sfx/ready/%s.wav"
	match card.Name:
		"gargoyles", "gargoylesquad":
			path = path % ["gargoylesquad"]
		_:
			path = path % [card.Name]
	return path

static func GetCursorScenePath(card):
	if card.Type == data.SquireCard:
		return "res://game/player/cursor/squire.tscn"
	return "res://game/unit/%s/skill_cursor.tscn" % [card.Unit]

static func GetReqResourcePathsInGame(card):
	var paths = [
		GetCardIconPathInGame(card.Name),
		GetUnitScenePath(card.Unit),
		GetCardReadySoundPath(card),
		GetCursorScenePath(card),
	]
	if card.Type == data.KnightCard:
		var skill = data.units[card.Unit].skill
		if skill.wing.has("unit"):
			paths.append(GetUnitScenePath(skill.wing.unit))
		if skill.leader.has("unit"):
			paths.append(GetUnitScenePath(skill.leader.unit))
	return paths