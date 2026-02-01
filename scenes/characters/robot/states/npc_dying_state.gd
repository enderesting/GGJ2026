extends State
class_name NPCDyingState


var animation_name: StringName = "sawblade_death"


func enter():
	character.animated_sprite_2d.play(animation_name)

func exit():
	# Remove? Is it here?
	pass

func process(_delta):
	pass

func physics_process(_delta):
	pass
