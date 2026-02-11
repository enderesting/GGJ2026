extends Button

func _ready() -> void:
	grab_focus()

func _pressed() -> void:
	# Prevent reduntant calls to Crossfade.fade_out()
	if SceneTransition.faded_out.is_connected(callLevel):
		return

	SceneTransition.fade_out()
	SceneTransition.faded_out.connect(callLevel, ConnectFlags.CONNECT_ONE_SHOT)

func callLevel():
	get_tree().change_scene_to_file("res://scenes/game_scene/THE_LEVEL/THE_LEVEL.tscn")
	SceneTransition.fade_in()
