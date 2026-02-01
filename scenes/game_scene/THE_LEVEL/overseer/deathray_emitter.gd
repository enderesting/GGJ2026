extends AnimatedSprite2D


func _ready() -> void:
	play("default")

func _process(delta: float) -> void:
	global_position.y = 0
