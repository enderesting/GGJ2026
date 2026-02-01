extends Control
class_name CrossFade

signal faded_in()
signal faded_out()

const SPEED : float = 2
@onready var color_rect: ColorRect = $ColorRect

var _fading_in := false
var _fading_out := false

func _ready() -> void:
	_fading_in = true

func fade_in():
	_fading_in = true

func fade_out():
	_fading_out = true

func _process(delta: float) -> void:
	if _fading_in:
		color_rect.color.a -= SPEED * delta
		if color_rect.color.a <= 0:
			color_rect.color.a = 0
			faded_in.emit()
			_fading_in = false
	if _fading_out:
		color_rect.color.a += SPEED * delta
		if color_rect.color.a >= 1:
			color_rect.color.a = 1
			faded_out.emit()
			_fading_out = false
	
