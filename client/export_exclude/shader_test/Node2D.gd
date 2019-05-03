extends Node2D

onready var w = ProjectSettings.get_setting("display/window/size/width")
onready var h = ProjectSettings.get_setting("display/window/size/height")

func _input(event):
    if event is  InputEventMouseMotion:
        var x = event.position.x / w
        var y = event.position.y / h
        $Absorber.material.set_shader_param("light_position_x", x)
        $Absorber.material.set_shader_param("light_position_y", y)