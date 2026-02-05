## THE PLAYER
extends Bot
class_name BotPlayer

func _exit_tree() -> void:
	EventBus.player_killed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("beep_boop") and $AnimatedSprite2D.animation == "RESET":
		$AnimatedSprite2D.play("beep_boop")
		$beep_boop.play()
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("RESET")
	if event.is_action_pressed("throw"):
		#throwing animation goes here
		$throw.play()


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
	
