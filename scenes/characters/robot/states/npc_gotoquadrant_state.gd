extends State
class_name NPCGotoQuadrantState

const GOAL_RADIUS: float = 20.0

var blessed_quadrant: Quadrant = null
var movement_goal := Vector2.ZERO

func enter():
	assert(blessed_quadrant, "RUNNING_TO_QUADRANT needs to have a blessed_quadrant assigned!")
	prints(character, "going to", blessed_quadrant,
		"with extents =", blessed_quadrant.get_extents(),
		"from", character.position)
	
	movement_goal = blessed_quadrant.get_extents().get_center() - character.position
	movement_goal += Vector2.RIGHT * randf_range(-20.0, 20.0)


func physics_process(_delta):
	if movement_goal.length() > GOAL_RADIUS:
		var this_step = character.SPEED * movement_goal.normalized().round().normalized()
		#printt(character, movement_goal, this_step)
		character.velocity = this_step
		character.move_and_slide()
		movement_goal -= character.get_position_delta() # this_step * _delta
