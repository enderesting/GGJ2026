extends Node2D

@onready var play_area = %PlayArea

#signal ray_shot
signal stop_moving
signal color_picked

@export_group("Traps")
@export_subgroup("4: Ze Quadrrantz")
@export var color_quadrants: Array[Quadrant]


func _ready() -> void:
	$Deathray.visible = false
	$Sawblade.visible = false
	$Stoplight.visible = false
	$Colorpicker.visible = false
	
	$Colorpicker/Color1.global_position = play_area.position - play_area.shape.size/4
	$Colorpicker/Color2.global_position = play_area.position - Vector2((-play_area.shape.size.x/4) ,play_area.shape.size.y/4)
	$Colorpicker/Color3.global_position = play_area.position + play_area.shape.size/4
	$Colorpicker/Color4.global_position = play_area.position - Vector2(play_area.shape.size.x/4 ,-(play_area.shape.size.y/4))
	$AnimationPlayer.play("overseer_idle")

func _input(event: InputEvent) -> void:

	# Trap 1: Death ray
	if event.is_action_pressed(&"trap_1"):
		$Deathray.position = play_area.position
		$Deathray.visible = true
		%Bolt.visible = false
		
	if event.is_action_released(&"trap_1"):
		var doomed_roamers: Array[Node2D] = %LaserHitArea.get_overlapping_bodies()
		for roamer in doomed_roamers:
			roamer.process_mode = Node.PROCESS_MODE_DISABLED
			
		%Bolt.visible = true
		%Bolt.play()
		await %Bolt.animation_finished
		$Deathray.visible = false
		for roamer in doomed_roamers:
			roamer.queue_free()
		
	
	# Trap 2: Sawblade
	if event.is_action_pressed(&"trap_2"):
		$Sawblade.global_position.x = play_area.position.x + play_area.shape.size.x/2
		$Sawblade.global_position.y =play_area.position.y
		$Sawblade.visible = true
	

	# Trap 3: Stop light
	if event.is_action_pressed(&"trap_3"):
		$Stoplight.visible = true
		$Stoplight.play()
		if $Stoplight.frame == 4:
			stop_moving.emit()
		await $Stoplight.animation_finished
		$Stoplight.visible = false
	

	# Trap 4: Color quadrants
	if event.is_action_pressed(&"trap_4"):
		do_quadrants()


func do_quadrants() -> void:
	for quadrant in color_quadrants:
		quadrant.animate_dramatic_flicker()
	await color_quadrants[0].animation_finished	
	
	var blessed_quadrant := color_quadrants.pick_random() as Quadrant
	await blessed_quadrant.animate_turn_on()
	
	color_picked.emit(blessed_quadrant.get_index() + 1)
	
	await get_tree().create_timer(2.0).timeout
	
	for quadrant in color_quadrants:
		if quadrant != blessed_quadrant:
			quadrant.kill_them_all()

	blessed_quadrant.animate_turn_off()
