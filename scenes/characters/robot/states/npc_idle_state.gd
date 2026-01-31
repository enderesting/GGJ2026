extends State
class_name NPCIdleState

var direction

func enter():
	character.goal = character.random_position()
	direction = random_dir()
	pass

func exit():
	pass

func process(delta):
	pass

func physics_process(delta):
	character.velocity = Vector2.ZERO

	if randf() <= 0.03:
		# change goal
		# character.goal = character.random_position()
		direction = random_dir()
		pass
	
	
	# if character.position.distance_to(character.goal) <= character.dist_to_goal:
	#     print("reached goal. changing")
	#     character.goal = character.random_position()
	# else:
	#     print("moving towards goal")
	#     character.velocity = character.position.direction_to(character.goal) * character.SPEED 
	#     character.move_and_slide()
	character.velocity = direction * character.SPEED
	# var wall_bump = 
	if character.move_and_slide():
		direction = (character.random_position()-character.position).normalized().round()

	# if randf() <= 0.5:
	#     character.velocity = -direction * character.SPEED
	

func random_dir():
	match randi_range(0,7): 
		0:
			return Vector2(0,1)
		1:
			return Vector2(1,1)
		2:
			return Vector2(1,0)
		3:
			return Vector2(1,-1)
		4:
			return Vector2(0,-1)
		5:
			return Vector2(-1,-1)
		6:
			return Vector2(-1,0)
		7:
			return Vector2(0,-1)
