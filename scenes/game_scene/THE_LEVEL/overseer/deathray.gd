extends CharacterBody2D

var play_area_position: Vector2

const SPEED = 300.0

func _ready() -> void:
	position = play_area_position

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"target_left", &"target_right", &"target_up", &"target_down")
	direction = direction.round().normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()
