extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	position = random_position()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	direction = direction.round().normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()

func random_position():
	return Vector2(
		randi_range(%PlayArea.position.x - %PlayArea.shape.size.x/2, %PlayArea.shape.size.x),
		randi_range(%PlayArea.position.y - %PlayArea.shape.size.y/2, %PlayArea.shape.size.y)
	)
	
