extends Node2D

@onready var play_area: CollisionShape2D = %PlayArea
@onready var cooldown: Timer = %TrapCooldown
@onready var warning_signs: AnimatedSprite2D = $WarningSigns

# Bad State
var can_trigger_trap := true
var charging_laser := false

#signal ray_shot
signal stop_moving
signal color_picked(blessed_quadrant: Quadrant)

signal trap_started(name: StringName)
signal trap_finished(name: StringName)
signal trap_cooldown()


func _ready() -> void:
	cooldown.timeout.connect(_on_cooldown_timeout)
	
	%Sawblade.body_entered.connect(func(body):
		if body is RobotNPC:
			body.states.DYING.animation_name = "sawblade_death"
			body.states.DYING.auto_free = true
			body.change_state(body.states.DYING)
		elif body is Player:
			body.queue_free())
	
	# pass through our signals to the EventBus
	trap_started.connect(EventBus.trap_started.emit)
	trap_finished.connect(EventBus.trap_finished.emit)
	trap_cooldown.connect(EventBus.trap_cooldown.emit)
	color_picked.connect(EventBus.trap_color_picked.emit)
	
	warning_signs.play("warning_idle")
	$Deathray.visible = false
	%Sawblade.visible = false
	$Stoplight.visible = false
	#$Colorpicker.visible = false
	
	#$Colorpicker/Color1.global_position = play_area.get_parent().position - play_area.shape.size/4
	#$Colorpicker/Color2.global_position = play_area.get_parent().position - Vector2((-play_area.shape.size.x/4) ,play_area.shape.size.y/4)
	#$Colorpicker/Color3.global_position = play_area.get_parent().position + play_area.shape.size/4
	#$Colorpicker/Color4.global_position = play_area.get_parent().position - Vector2(play_area.shape.size.x/4 ,-(play_area.shape.size.y/4))
	$AnimationPlayer.play("overseer_idle")


func _on_cooldown_timeout():
	trap_cooldown.emit()
	can_trigger_trap = true


func _input(event: InputEvent) -> void:
	# Trap 1: Death ray
	if event.is_action_pressed(&"trap_laser") and can_trigger_trap:
		can_trigger_trap = false
		charging_laser = true
		warning_signs.play("warning_die")
		$Deathray.speed = 300
		$Deathray.position = play_area.get_parent().position
		$Deathray.visible = true
		$Deathray/AudioStreamPlayer.play()
		%Bolt.visible = false
		
	if event.is_action_released(&"trap_laser") and charging_laser:
		charging_laser = false
		$Deathray/AudioStreamPlayer.stop()
		$Deathray/AudioStreamPlayer2.play()
		cooldown.start()
		trap_started.emit(&"trap_laser")
		$Deathray.speed = 0
		var doomed_roamers: Array[Node2D] = %LaserHitArea.get_overlapping_bodies()
		for roamer in doomed_roamers:
			if roamer is RobotNPC:
				roamer.states.DYING.animation_name = "lightning_death"
				roamer.states.DYING.auto_free = false
				roamer.change_state(roamer.states.DYING)
			
		%Bolt.visible = true
		%Bolt.play()
		await %Bolt.animation_finished
		$Deathray.visible = false
		for roamer in doomed_roamers:
			roamer.queue_free()
		
		trap_finished.emit(&"trap_laser")
		warning_signs.play(&"warning_idle")

	
	# Trap 2: Sawblade
	if event.is_action_pressed(&"trap_saw") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		warning_signs.play("warning_run")
		trap_started.emit(&"trap_saw")
		$SawbladeClipHack/Sawblade/AudioStreamPlayer.play()
		%Sawblade.global_position.x = play_area.get_parent().position.x + play_area.shape.size.x/2
		%Sawblade.global_position.y = play_area.get_parent().position.y + 50
		%Sawblade.visible = true
		create_tween() \
			.tween_property(%Sawblade, ^"global_position:y", -50, 0.5) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD) \
			.as_relative()
		await create_tween() \
			.tween_property(%Sawblade, ^"global_position:x", 60, 1.0) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT) \
			.finished
		$SawbladeClipHack/Sawblade/AudioStreamPlayer.stop()
		%Sawblade.visible = false
		trap_finished.emit(&"trap_saw")
		warning_signs.play(&"warning_idle")


	# Trap 3: Stop light
	if event.is_action_pressed(&"trap_stop") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		warning_signs.play("warning_stop")
		trap_started.emit(&"trap_stop")
		$Stoplight.visible = true
		$Stoplight.play()
		while $Stoplight.frame < 4:
			await $Stoplight.frame_changed
		stop_moving.emit()
		await $Stoplight.animation_finished
		$Stoplight.visible = false
		warning_signs.play(&"warning_idle")
		trap_finished.emit(&"trap_stop")

	# Trap 4: Color quadrants
	if event.is_action_pressed(&"trap_color") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		warning_signs.play("warning_go")
		trap_started.emit(&"trap_color")
		await do_quadrants()
		trap_finished.emit(&"trap_color")
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
