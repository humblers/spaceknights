extends RigidBody

var damage = 1
var life_timer = 0
var decay_time = 1
var is_critical = false
var material_01 = FixedMaterial.new()
var material_02 = FixedMaterial.new()
export var is_2d = false

var time = 0

func _ready():
	add_to_group("bullet")
	if is_in_group('player'):
		material_01.set_parameter(material_01.PARAM_DIFFUSE,Color(0.2,0.2,0.7,1))
		get_node("MeshInstance").set_material_override(material_01)

	if is_critical:
		material_02.set_parameter(material_02.PARAM_DIFFUSE,Color(0,1,0,1))
		get_node("MeshInstance").set_material_override(material_02)
	
	if is_2d:
		if get_node("MeshInstance").is_visible():
			get_node("MeshInstance").hide()
		get_node("Node2D").show()
	else:
		if get_node("Node2D").is_visible():
			get_node("MeshInstance").show()
			get_node("Node2D").hide()
	set_process(true)

func _process(delta):
	if is_2d:
		get_node("Node2D/Sprite").set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))

	life_timer += delta
	if life_timer > decay_time:
		queue_free()
		life_timer = 0

	time += delta*20
	if is_critical:
		var color = (sin(time)+1)/2*0.5
		material_02.set_parameter(material_02.PARAM_DIFFUSE,Color(color+0.5,color+0.5,color/2,color+0.5))
		get_node("MeshInstance").set_material_override(material_02)

func _on_Bullet_body_enter( body ):
	if not variants.is_opponent(self, body):
		return
	if body.is_in_group("mothership") or body.is_in_group("knight") or body.is_in_group("charge") or body.is_in_group("drone") or body.is_in_group("blackhole"):
		queue_free()