extends Control

func _ready() -> void:
	$RichTextLabel.visible_ratio = 0.0
	create_tween().tween_property($RichTextLabel, ^"visible_ratio", 1.0, 0.25)
