
# state.gd
class_name State
extends RefCounted # Inherit RefCounted for automatic memory management

var character: Node

func enter():
    pass

func exit():
    pass

func process(delta):
    pass

func physics_process(delta):
    pass
