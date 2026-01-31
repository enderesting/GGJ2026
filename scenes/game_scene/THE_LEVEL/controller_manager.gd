extends Node2D

#prompt user to press any button for overseer then for robot
#cannot be same controller
#differentiate roller and keeb
#player assignement can come from a signal

var overseer
var bad_robot

func _input(event: InputEvent) -> void:
	#var device_id = event.device
	
	#print("press a button")
	#ask for button player 1
	
	if event is InputEventKey:
		overseer = event.device
		#print("kb")
		
	if event is InputEventJoypadButton or InputEventJoypadMotion:
		overseer = event.device
		#print("controller")
		


func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass
