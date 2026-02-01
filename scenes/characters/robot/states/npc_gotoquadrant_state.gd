extends State
class_name NPCGotoQuadrantState

var blessed_quadrant: Quadrant = null

func enter():
	assert(blessed_quadrant, "RUNNING_TO_QUADRANT needs to have a blessed_quadrant assigned!")
	


func exit():
	pass


func process(delta):
	super(delta)


func physics_process(delta):
	super(delta)
