extends Node2D
class_name Overseer


class Slowdown:
	const SCALE: float = 0.3
	const DURATION: float = 0.2
	
	static func start_slowdown(some_node):
		some_node.create_tween().tween_property(Engine, "time_scale", SCALE, DURATION) \
			.set_trans(Tween.TRANS_SINE)
	
	static func end_slowdown(some_node):
		some_node.create_tween().tween_property(Engine, "time_scale", 1.0, DURATION) \
			.set_trans(Tween.TRANS_SINE)

# Nodes that need to be given
@export var play_area: RectangularArea

# Nodes within ourselves
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

#region life

signal died()

@export var max_life: int = 10
@onready var life := max_life

@onready var sprite := $OverseerSprite as Node2D

func take_damage():
	life -= 1
	
	if life == 0:
		die()

func die():
	# TODO animate it manually with an AnimationPlayer
	var tween := create_tween()
	tween.set_loops(4)
	tween.tween_callback(sprite.hide)
	tween.tween_interval(0.125)
	tween.tween_callback(sprite.show)
	tween.tween_interval(0.125)
	await tween.finished
	sprite.visible = false
	died.emit()



#endregion


func _ready() -> void:
	cooldown.timeout.connect(_on_cooldown_timeout)

	%Sawblade.body_entered.connect(func(body):
		if body is Bot:
			body.states.DYING.animation_name = "sawblade_death"
			body.states.DYING.auto_free = true
			body.change_state(body.states.DYING)
	)
						
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

	#$Colorpicker/Color1.global_position = play_area.get_extents().position - play_area.shape.size/4
	#$Colorpicker/Color2.global_position = play_area.get_extents().position - Vector2((-play_area.shape.size.x/4) ,play_area.shape.size.y/4)
	#$Colorpicker/Color3.global_position = play_area.get_extents().position + play_area.shape.size/4
	#$Colorpicker/Color4.global_position = play_area.get_extents().position - Vector2(play_area.shape.size.x/4 ,-(play_area.shape.size.y/4))
	$AnimationPlayer.play("overseer_idle")


func _on_cooldown_timeout():
	trap_cooldown.emit()
	can_trigger_trap = true


func _input(event: InputEvent) -> void:
	# Trap 1: Death ray
	
	if event.is_action_pressed(&"trap_laser") and can_trigger_trap:
		#if not charging_laser:
		can_trigger_trap = false
		charging_laser = true
		warning_signs.play("warning_die")
		$Deathray.speed = 300
		$Deathray.position = play_area.get_extents().get_center()
		$Deathray.visible = true
		$Deathray/AudioStreamPlayer.play()
		return

	if event.is_action_pressed(&"trap_laser") and charging_laser:
		$Deathray/AudioStreamPlayer.stop()
		$Deathray/AudioStreamPlayer2.play()
		cooldown.start()
		trap_started.emit(&"trap_laser")
		$Deathray.speed = 0
		var doomed_roamer_hitboxes: Array[Area2D] = %LaserHitArea.get_overlapping_areas()
		#print(doomed_roamer_hitboxes.size())
		var doomed_roamers: Array[Node2D]
		for roamer_hitbox in doomed_roamer_hitboxes:
			var roamer = roamer_hitbox.get_parent()
			#print(roamer)
			if roamer is Bot:
				doomed_roamers.append(roamer)
				roamer.states.DYING.animation_name = "lightning_death"
				if roamer is BotPlayer:
					roamer.states.DYING.animation_name = "lightning_death_human"
				roamer.states.DYING.auto_free = false
				roamer.change_state(roamer.states.DYING)
		%Bolt.play()
		create_tween().tween_property(%CanvasModulate, "color", Color(0.082, 0.102, 0.118), 0.125).set_trans(Tween.TRANS_BOUNCE)
		Slowdown.start_slowdown(self)
		await %Bolt.animation_finished
		Slowdown.end_slowdown(self)
		create_tween().tween_property(%CanvasModulate, "color", Color(1, 1, 1), 0.25)
		
		$Deathray.visible = false
		for roamer in doomed_roamers:
			roamer.queue_free()
		trap_finished.emit(&"trap_laser")
		warning_signs.play(&"warning_idle")
		charging_laser = false
	
	# Trap 2: Sawblade
	if event.is_action_pressed(&"trap_saw") and can_trigger_trap:
		can_trigger_trap = false
		cooldown.start()
		warning_signs.play("warning_run")
		trap_started.emit(&"trap_saw")
		$SawbladeClipHack/Sawblade/AudioStreamPlayer.play()
		%Sawblade.global_position.x = play_area.get_extents().get_support(Vector2.RIGHT).x
		%Sawblade.global_position.y = play_area.get_extents().get_center().y + 50
		%Sawblade.visible = true
		
		# Delay collision detection for about a half of the time it takes to animate up
		%Sawblade.monitoring = false
		get_tree().create_timer(0.125).timeout.connect(func():
			%Sawblade.monitoring = true)
		
		Slowdown.start_slowdown(self)
		
		(
			create_tween()
				.tween_property(%Sawblade, ^"global_position:y", -50, 0.25)
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
				.as_relative()
		)
		await (
			create_tween()
				.tween_property(%Sawblade, ^"global_position:x", 60, 1.0 * Slowdown.SCALE)
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
				.finished
		)
		Slowdown.end_slowdown(self)
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
	var quadrants: Array[Quadrant] = Quadrant.get_nodes_in_group(get_tree())

	for quadrant in quadrants:
		quadrant.animate_dramatic_flicker()

	await quadrants[0].animation_finished

	var blessed_quadrant : Quadrant = quadrants.pick_random()
	var killing_quadrants : Array[Quadrant] = quadrants.filter(func(quadrant):
		return quadrant != blessed_quadrant)

	await blessed_quadrant.animate_turn_on()
	color_picked.emit(blessed_quadrant)

	for quadrant in killing_quadrants:
		quadrant.animate_floor_lightning_charging()
	await killing_quadrants[0].animation_finished

	$Deathray/AudioStreamPlayer2.play()
	for quadrant in killing_quadrants:
		quadrant.kill_them_all()

	await get_tree().create_timer(2.0).timeout
	for quadrant in quadrants:
		quadrant.turn_off()

	return blessed_quadrant.animate_turn_off()
