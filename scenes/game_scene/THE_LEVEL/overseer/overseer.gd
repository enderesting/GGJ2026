extends Node2D

@onready var play_area: CollisionShape2D = %PlayArea
@onready var cooldown: Timer = %TrapCooldown
@onready var warning_signs: AnimatedSprite2D = $WarningSigns

var can_trigger_trap := true

#signal ray_shot
signal stop_moving
signal color_picked(blessed_quadrant: Quadrant)

signal trap_started(name: StringName)
signal trap_finished(name: StringName)
signal trap_cooldown()


func _ready() -> void:
	cooldown.timeout.connect(_on_cooldown_timeout)
	
	# pass through our signals to the EventBus
	trap_started.connect(EventBus.trap_started.emit)
	trap_finished.connect(EventBus.trap_finished.emit)
	trap_cooldown.connect(EventBus.trap_cooldown.emit)
	color_picked.connect(EventBus.trap_color_picked.emit)
	
	warning_signs.play("warning_idle")
	$Deathray.visible = false
	$Sawblade.visible = false
	$Stoplight.visible = false
	$Colorpicker.visible = false
	
	$Colorpicker/Color1.global_position = play_area.get_parent().position - play_area.shape.size/4
	$Colorpicker/Color2.global_position = play_area.get_parent().position - Vector2((-play_area.shape.size.x/4) ,play_area.shape.size.y/4)
	$Colorpicker/Color3.global_position = play_area.get_parent().position + play_area.shape.size/4
	$Colorpicker/Color4.global_position = play_area.get_parent().position - Vector2(play_area.shape.size.x/4 ,-(play_area.shape.size.y/4))
	$AnimationPlayer.play("overseer_idle")


func _on_cooldown_timeout():
	trap_cooldown.emit()
	can_trigger_trap = true


func _input(event: InputEvent) -> void:
	#if not can_trigger_trap:
		#return
	
	# Trap 1: Death ray
	if event.is_action_pressed(&"trap_1") and can_trigger_trap:
		warning_signs.play("warning_die")
		$Deathray.position = play_area.get_parent().position
		$Deathray.visible = true
		%Bolt.visible = false
		
	if event.is_action_released(&"trap_1") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		trap_started.emit(&"trap_1")
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
		warning_signs.play(&"warning_idle")

	
	# Trap 2: Sawblade
	if event.is_action_pressed(&"trap_2") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		warning_signs.play("warning_run")
		trap_started.emit(&"trap_2")
		$Sawblade.global_position.x = play_area.get_parent().position.x + play_area.shape.size.x/2
		$Sawblade.global_position.y =play_area.get_parent().position.y
		$Sawblade.visible = true
		trap_finished.emit(&"trap_2")
		warning_signs.play(&"warning_idle")


	# Trap 3: Stop light
	if event.is_action_pressed(&"trap_3") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		warning_signs.play("warning_stop")
		trap_started.emit(&"trap_3")
		$Stoplight.visible = true
		$Stoplight.play()
		if $Stoplight.frame == 4:
			stop_moving.emit()
		await $Stoplight.animation_finished
		$Stoplight.visible = false
		trap_finished.emit(&"trap_3")
		warning_signs.play(&"warning_idle")

	# Trap 4: Color quadrants
	if event.is_action_pressed(&"trap_4") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		warning_signs.play("warning_go")
		trap_started.emit(&"trap_4")
		await do_quadrants()
		trap_finished.emit(&"trap_4")
		warning_signs.play(&"warning_idle")


func do_quadrants() -> void:
	# Retrieve quadrants type-safely
	var quadrants: Array[Quadrant] = []
	for quadrant in get_tree().get_nodes_in_group("quadrants"):
		if quadrant is Quadrant:
			quadrants.push_back(quadrant)
	
	for quadrant in quadrants:
		quadrant.animate_dramatic_flicker()
	await quadrants[0].animation_finished	
	
	var blessed_quadrant := quadrants.pick_random() as Quadrant
	await blessed_quadrant.animate_turn_on()
	
	color_picked.emit(blessed_quadrant)
	
	await get_tree().create_timer(2.0).timeout
	
	for quadrant in quadrants:
		if quadrant != blessed_quadrant:
			quadrant.kill_them_all()

	return blessed_quadrant.animate_turn_off()
