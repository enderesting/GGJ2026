extends Sprite2D
@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	EventBus.trap_finished.connect(_on_trap_finished)


func _on_trap_finished(_trap_name):
	(create_tween()
		.tween_property(progress_bar, ^"value", progress_bar.min_value,
			Globals.match_trap_cooldown)
		.from(progress_bar.max_value)
		.set_trans(Tween.TRANS_LINEAR))
