extends Node2D

func _on_timer_timeout() -> void:
	kys()

func _on_overseer_died() -> void:
	kys()

func kys() -> void:
	await SceneTransition.fade_out()
	SceneTransition.fade_in()
	get_tree().change_scene_to_file("res://scenes/game_scene/endings/imposter_win.tscn")


func _on_player_tree_exiting() -> void:
	player_dies()

func player_dies() -> void:
	await SceneTransition.fade_out()
	SceneTransition.fade_in()
	get_tree().change_scene_to_file("res://scenes/game_scene/endings/seer_win.tscn")
