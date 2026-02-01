extends Button


func _pressed() -> void:
	Crossfade.fade_out()
	Crossfade.faded_out.connect( func():
			get_tree().change_scene_to_file("res://scenes/game_scene/THE_LEVEL/THE_LEVEL.tscn")
			Crossfade.fade_in()
	)
