extends Control
class_name CrossFade

signal faded_in()
signal faded_out()

const SPEED : float = 2

var cover_tween := create_tween()
var uncover_tween := create_tween()

@onready var color_rect: ColorRect = $ColorRect


func _init() -> void:
	cover_tween.tween_method(_update_shader, 0.0, 1.0, 1 / SPEED)
	cover_tween.stop()
	uncover_tween.tween_method(_update_shader, 1.0, 0.0, 1 / SPEED)
	uncover_tween.stop()

	cover_tween.finished.connect(func():
		cover_tween.stop()
		faded_out.emit())

	uncover_tween.finished.connect(func():
		color_rect.hide()
		uncover_tween.stop()
		faded_in.emit())


func _ready() -> void:
	_update_shader(0.0)


func fade_in() -> Signal:
	uncover_tween.play()
	return faded_in


func fade_out() -> Signal:
	color_rect.show()
	cover_tween.play()
	return faded_out


func _update_shader(progress: float) -> void:
	(color_rect.material as ShaderMaterial).set_shader_parameter("progress", progress)
