extends Node2D

func _on_timer_timeout() -> void:
	Crossfade.fade_out()
	Crossfade.faded_out.connect(kys)

func _on_overseer_died() -> void:
	Crossfade.fade_out()
	Crossfade.faded_out.connect(kys)

func kys() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene/endings/imposter_win.tscn")
	Crossfade.fade_in()
	Crossfade.faded_out.disconnect(kys)
	


func _on_player_tree_exiting() -> void:
	Crossfade.fade_out()
	Crossfade.faded_out.connect(player_dies)
	
func player_dies() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene/endings/seer_win.tscn")
	Crossfade.fade_in()
	Crossfade.faded_out.disconnect(player_dies)
	
