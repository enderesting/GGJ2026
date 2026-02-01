extends Control

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene/main_menu/main_menu2.tscn")
