extends Node2D

func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	Crossfade.fade_out()
	Crossfade.faded_out.connect(kys)

func kys() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene/endings/imposter_win.tscn")
	Crossfade.fade_in()
	Crossfade.faded_out.disconnect(kys)
	
