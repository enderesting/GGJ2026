extends CharacterBody2D
class_name RoamingRobot

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Both robots and masker should inherit the movable class. Maybe give it a better name though
func _ready():
	position = random_position()

func _physics_process(_delta: float) -> void:
	pass

func random_position():
	return Vector2(
		randi_range(%PlayArea.position.x - %PlayArea.shape.size.x/2, %PlayArea.shape.size.x),
		randi_range(%PlayArea.position.y - %PlayArea.shape.size.y/2, %PlayArea.shape.size.y)
	)
	