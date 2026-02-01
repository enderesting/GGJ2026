extends Control

func _ready() -> void:
	$RichTextLabel.visible_ratio = 0.0
	create_tween().tween_property($RichTextLabel, ^"visible_ratio", 1.0, 0.25)

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene/main_menu/main_menu2.tscn")
