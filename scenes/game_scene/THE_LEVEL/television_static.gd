extends ColorRect


func _ready() -> void:
	EventBus.trap_started.connect(_on_trap_started)
	EventBus.trap_finished.connect(_on_trap_finished)


func _on_trap_started(_trap_name):
	(create_tween()
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		.tween_property(self, ^"modulate:a", 0.0, 0.25))


func _on_trap_finished(_trap_name):
	(create_tween()
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		.tween_property(self, ^"modulate:a", 1.0, 0.5))
