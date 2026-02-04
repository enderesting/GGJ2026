## THE PLAYER
extends RoamingRobot
class_name Player

func _exit_tree() -> void:
	EventBus.player_killed.emit()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	direction = direction.round().normalized()
	if direction:
		velocity = direction * SPEED
		if velocity.x:
			get_child(0).flip_h = velocity.x > 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()
	
