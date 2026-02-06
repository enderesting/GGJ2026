extends Sprite2D
@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	EventBus.trap_finished.connect(
		func(x):
			create_tween()\
			.tween_property(progress_bar,"value",0,GlobalVariables.TRAP_COOLDOWN)\
			.from(100))
