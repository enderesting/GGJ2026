extends CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
