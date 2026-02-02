extends Button

func _ready() -> void:
	# Disable the button on web
	disabled = OS.has_feature("web")


## Exits the game, unless it's running on web, as that would just leave the game
## frozen on the page
func _pressed() -> void:
	if OS.has_feature("web"):
		return

	get_tree().quit()
