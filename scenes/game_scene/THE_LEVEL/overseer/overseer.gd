extends Node2D

@onready var play_area: CollisionShape2D = %PlayArea
@onready var cooldown: Timer = %TrapCooldown

#signal ray_shot
signal stop_moving
signal color_picked

signal trap_started(name: StringName)
signal trap_finished(name: StringName)
signal trap_cooldown()

#@export_group("Traps")
#@export_subgroup("4: Ze Quadrrantz")
# I decided to use groups instead - more game jamy - more... godotesque
#@export var quadrants: Array[Quadrant]


func _ready() -> void:
	# pass through cooldown timeout signal to trap_cooldown
	cooldown.timeout.connect(trap_cooldown.emit)
	
	$Deathray.visible = false
	$Sawblade.visible = false
	$Stoplight.visible = false
	$Colorpicker.visible = false
	
	$Colorpicker/Color1.global_position = play_area.get_parent().position - play_area.shape.size/4
	$Colorpicker/Color2.global_position = play_area.get_parent().position - Vector2((-play_area.shape.size.x/4) ,play_area.shape.size.y/4)
	$Colorpicker/Color3.global_position = play_area.get_parent().position + play_area.shape.size/4
	$Colorpicker/Color4.global_position = play_area.get_parent().position - Vector2(play_area.shape.size.x/4 ,-(play_area.shape.size.y/4))
	$AnimationPlayer.play("overseer_idle")

func _input(event: InputEvent) -> void:
	# Trap 1: Death ray
	if event.is_action_pressed(&"trap_1") and cooldown.is_stopped():
		trap_started.emit(&"trap_1")
		$Deathray.position = play_area.get_parent().position
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
		
		trap_finished.emit(&"trap_1")
		
	
	# Trap 2: Sawblade
	if event.is_action_pressed(&"trap_2") and cooldown.is_stopped():
		trap_started.emit(&"trap_2")
		$Sawblade.global_position.x = play_area.get_parent().position.x + play_area.shape.size.x/2
		$Sawblade.global_position.y =play_area.get_parent().position.y
		$Sawblade.visible = true
		trap_finished.emit(&"trap_2")
	

	# Trap 3: Stop light
	if event.is_action_pressed(&"trap_3") and cooldown.is_stopped():
		trap_started.emit(&"trap_3")
		$Stoplight.visible = true
		$Stoplight.play()
		if $Stoplight.frame == 4:
			stop_moving.emit()
		await $Stoplight.animation_finished
		$Stoplight.visible = false
		trap_finished.emit(&"trap_3")
	

	# Trap 4: Color quadrants
	if event.is_action_pressed(&"trap_4") and cooldown.is_stopped():
		trap_started.emit(&"trap_4")
		await do_quadrants()
		cooldown.start()
		trap_finished.emit(&"trap_4")


func do_quadrants() -> void:
	var quadrants : Array[Quadrant] = []
	for quadrant in get_tree().get_nodes_in_group("quadrants"):
		if quadrant is Quadrant:
			quadrants.push_back(quadrant)
	
	for quadrant in quadrants:
		quadrant.animate_dramatic_flicker()
	await quadrants[0].animation_finished	
	
	var blessed_quadrant := quadrants.pick_random() as Quadrant
	await blessed_quadrant.animate_turn_on()
	
	color_picked.emit(blessed_quadrant.get_index() + 1)
	
	await get_tree().create_timer(2.0).timeout
	
	for quadrant in quadrants:
		if quadrant != blessed_quadrant:
			quadrant.kill_them_all()

	return blessed_quadrant.animate_turn_off()
