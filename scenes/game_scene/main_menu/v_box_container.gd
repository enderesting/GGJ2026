extends VBoxContainer

@export var children_shader: Shader = preload("uid://cpkuc68tu41hp")


func _ready() -> void:
	var shader_material := ShaderMaterial.new()
	shader_material.shader = children_shader
	
	for child in get_children():
		if child is Button:
			child.material = shader_material
			if child.has_focus():
				child.set_instance_shader_parameter("delay", 0)
				child.set_instance_shader_parameter("offset", 150)
			else:
				child.set_instance_shader_parameter("delay",  0.05 + 0.05 * child.get_index())
