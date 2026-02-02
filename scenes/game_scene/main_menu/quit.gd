extends Button

func _ready() -> void:
	# Remove this button from the layout for the web export
	visible = not OS.has_feature("web")

func _pressed() -> void:
	get_tree().quit()
