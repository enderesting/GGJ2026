## state.gd:
## Abstract base class for states
class_name State
extends RefCounted # Inherit RefCounted for automatic memory management

var character: Bot

func enter():
	pass

func exit():
	pass

func process(_delta):
	pass

func physics_process(_delta):
	pass

func handle_input(event: InputEvent) -> void:
	pass
