extends Node2D

func _on_timer_timeout() -> void:
	#await SceneTransition.fade_out()
	get_tree().change_scene_to_file("res://scenes/game_scene/main_menu/main_menu2.tscn")
	#SceneTransition.fade_in()
