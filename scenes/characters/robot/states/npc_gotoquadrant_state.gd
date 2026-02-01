extends State
class_name NPCGotoQuadrantState

const GOAL_RADIUS: float = 24.0

var blessed_quadrant: Quadrant = null
var movement_goal := Vector2.ZERO

func enter():
	assert(blessed_quadrant, "RUNNING_TO_QUADRANT needs to have a blessed_quadrant assigned!")
	
	var goal_rect := blessed_quadrant.get_extents().grow(-20)
	var goal_point := goal_rect.position + Vector2(
		goal_rect.size.x * randf(),
		goal_rect.size.y * randf()
	)
	movement_goal = goal_point - character.position


func physics_process(_delta):
	if movement_goal.length() > GOAL_RADIUS:
		var this_step = character.SPEED * movement_goal.normalized().round().normalized()
		#printt(character, movement_goal, this_step)
		character.velocity = this_step
		character.move_and_slide()
		movement_goal -= character.get_position_delta() # this_step * _delta
