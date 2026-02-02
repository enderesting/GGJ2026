extends CharacterBody2D

var play_area_position: Vector2
var stopped: bool

var speed = 300.0

func _ready() -> void:
	position = play_area_position

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"target_left", &"target_right", &"target_up", &"target_down")
	direction = direction.round().normalized()
	if direction: #and not stopped:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()


func _on_overseer_trap_started(_name: StringName) -> void:
	stopped = true
	

func _on_overseer_trap_finished(_name: StringName) -> void:
	stopped = false
