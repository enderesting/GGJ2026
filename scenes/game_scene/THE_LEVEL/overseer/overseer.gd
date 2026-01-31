extends Node2D

func _ready() -> void:
	$Deathray.visible = false
	$Sawblade.visible = false
	
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"trap_1"):
		$Deathray.position = %PlayArea.position
		$Deathray.visible = true
		
	if Input.is_action_just_released(&"trap_1"):
		$Deathray.visible = false
		
	if Input.is_action_just_pressed(&"trap_2"):
		$Sawblade.position.x = %PlayArea.shape.size.x
		$Sawblade.position.y = %PlayArea.shape.size.y
		print(%PlayArea.shape.size)
		$Sawblade.visible = true
		
	if Input.is_action_just_pressed(&"trap_3"):
		print("trap3")
	if Input.is_action_just_pressed(&"trap_4"):
		print("trap4")
