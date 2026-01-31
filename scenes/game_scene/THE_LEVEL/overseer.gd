extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"trap_1"):
		print("trap1")
	if Input.is_action_just_pressed("trap_2"):
		print("trap2")
	if Input.is_action_just_pressed("trap_3"):
		print("trap3")
	if Input.is_action_just_pressed("trap_4"):
		print("trap4")
