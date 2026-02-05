extends State
class_name ShootingState

var direction

func enter():
	character.goal = character.play_area.get_random_position()

func exit():
	pass

func process(_delta):
	pass

func physics_process(_delta):
	pass
