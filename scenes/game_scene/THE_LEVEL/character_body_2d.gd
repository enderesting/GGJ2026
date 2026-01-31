extends CharacterBody2D

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	print(dir)
	velocity = dir
	move_and_slide()
