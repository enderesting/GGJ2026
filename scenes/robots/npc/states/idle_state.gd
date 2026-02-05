extends State
class_name IdleState

func enter():
	pass

func exit():
	pass
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("beep_boop") and character.spriteAnimator.animation == "RESET":
		character.spriteAnimator.play("beep_boop")
		character.beep_boop_sound.play()
		await character.spriteAnimator.animation_finished
		character.spriteAnimator.play("RESET")
	if event.is_action_pressed("throw"):
		#throwing animation goes here
		character.throw_sound.play()
		var projectile := preload("res://scenes/robots/player/projectiles/projectile.tscn").instantiate() as Node2D
		projectile.top_level = true
		projectile.global_position = character.global_position
		projectile.z_index = 1000
		projectile.z_as_relative = false
		character.add_child(projectile)
		
func physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	direction = direction.round().normalized()
	if direction:
		character.velocity = direction * character.SPEED
		if character.velocity.x:
			character.get_child(0).flip_h = character.velocity.x > 0
	else:
		character.velocity = character.velocity.move_toward(Vector2.ZERO, character.SPEED)
	
	character.move_and_slide()
