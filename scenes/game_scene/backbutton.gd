extends Button

func _ready() -> void:
	grab_focus()

func _pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene/main_menu/main_menu2.tscn")
