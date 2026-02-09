extends Node2D
class_name Overseer
## Overseer Demigod Class

signal stop_moving()
signal color_picked(blessed_quadrant: Quadrant)

signal trap_started(name: StringName)
signal trap_finished(name: StringName)
signal trap_cooldown()

@export var play_area: RectangularArea

# Evil State (that caused us bugs in the game displayed at the jam)
var can_trigger_trap := true
var charging_laser := false

@onready var slowdown_fx := SlowdownFX.new(self)
@onready var modulate_fx := ModulateFX.new(%CanvasModulate)
@onready var cooldown: Timer = %TrapCooldown
@onready var warning_signs: AnimatedSprite2D = $WarningSigns

#region life
signal died()

@export var max_life: int = 10
@onready var life := max_life

@onready var sprite := $OverseerSprite as Node2D

func take_damage():
	$AnimationPlayer.play("overseer_hit")
	$AnimationPlayer.seek(0)
	await($AnimationPlayer.animation_finished)
	if life / float(max_life) <= 0.5:
		$AnimationPlayer.play("overseer_late")
	# if life/max_life <= 0.3:
		# $AnimationPlayer.play("overseer_late")
	else:
		$AnimationPlayer.play("overseer_idle")

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
	cooldown.wait_time = Globals.match_trap_cooldown
	cooldown.timeout.connect(_on_cooldown_timeout)

	%Sawblade.body_entered.connect(_on_sawblade_body_entered)

	# pass through our signals to the EventBus
	trap_started.connect(EventBus.trap_started.emit)
	trap_finished.connect(EventBus.trap_finished.emit)
	trap_cooldown.connect(EventBus.trap_cooldown.emit)
	color_picked.connect(EventBus.trap_color_picked.emit)

	warning_signs.play("warning_idle")
	$Deathray.visible = false
	%Sawblade.visible = false
	$Stoplight.visible = false
	$AnimationPlayer.play("overseer_idle")


func _unhandled_input(event: InputEvent) -> void:
	# Saw, stop and color traps have identical setup and teardown boilerplate
	var traps: Dictionary[StringName, Dictionary] = {
		&"trap_saw": {
			warning_animation = &"warning_run",
			method = _do_sawblade,
		},
		&"trap_stop": {
			warning_animation = &"warning_stop",
			method = _do_stop,
		},
		&"trap_color": {
			warning_animation = &"warning_go",
			method = _do_quadrants,
		},
	}

	for trap_name in traps:
		var input_action_name := trap_name
		var trap := traps[trap_name]

		if event.is_action_pressed(input_action_name) and can_trigger_trap:
			# Setup
			can_trigger_trap = false
			warning_signs.play(trap.warning_animation)
			trap_started.emit(trap_name)

			# Execution
			await trap.method.call()

			# Teardown
			trap_finished.emit(trap_name)
			warning_signs.play(&"warning_idle")
			cooldown.start()

			# Don't process more traps
			return
	
	# Special input handling for laser trap charging and shooting:
	# First press initiates laser aiming
	if event.is_action_pressed(&"trap_laser") and can_trigger_trap:
		can_trigger_trap = false
		charging_laser = true
		warning_signs.play("warning_die")
		trap_started.emit(&"trap_laser")
		_do_deathray_charging()
		return

	# Second press shoots the laser
	if event.is_action_pressed(&"trap_laser") and charging_laser:
		charging_laser = false
		cooldown.start()
		await _do_deathray_shot()
		trap_finished.emit(&"trap_laser")
		warning_signs.play(&"warning_idle")
		return


func _on_cooldown_timeout():
	trap_cooldown.emit()
	can_trigger_trap = true


func _on_sawblade_body_entered(body: Node2D) -> void:
	if body is Bot:
		body.states.DYING.animation_name = "sawblade_death"
		body.states.DYING.auto_free = true
		body.change_state(body.states.DYING)


func _do_deathray_charging() -> void:
	$Deathray.speed = GlobalVariables.DEATHRAY_SPEED
	$Deathray.position = play_area.get_extents().get_center()
	$Deathray.visible = true
	$Deathray/AudioStreamPlayer.play()


func _do_deathray_shot() -> void:
	$Deathray/AudioStreamPlayer.stop()
	$Deathray/AudioStreamPlayer2.play()
	$Deathray.speed = 0

	var doomed_roamer_hitboxes: Array[Area2D] = %LaserHitArea.get_overlapping_areas()
	var doomed_roamers: Array[Node2D]
	for roamer_hitbox in doomed_roamer_hitboxes:
		var roamer = roamer_hitbox.get_parent()
		if roamer is Bot:
			doomed_roamers.append(roamer)
			roamer.states.DYING.animation_name = "lightning_death"
			if roamer is BotPlayer:
				roamer.states.DYING.animation_name = "lightning_death_human"
			roamer.states.DYING.auto_free = false
			roamer.change_state(roamer.states.DYING)

	%Bolt.show()
	%Bolt.play()

	modulate_fx.lights_off(0.75)
	slowdown_fx.start_slowdown()
	await %Bolt.animation_finished
	slowdown_fx.end_slowdown()
	modulate_fx.lights_on()
	
	%Bolt.hide()
	$Deathray.hide()

	for roamer in doomed_roamers:
		roamer.queue_free()


func _do_sawblade() -> void:
	$SawbladeClipHack/Sawblade/AudioStreamPlayer.play()
	%Sawblade.global_position.x = play_area.get_extents().get_support(Vector2.RIGHT).x
	%Sawblade.global_position.y = play_area.get_extents().get_center().y + 50
	%Sawblade.visible = true

	# Delay collision detection for about a half of the time it takes to animate up
	%Sawblade.monitoring = false
	get_tree().create_timer(0.125).timeout.connect(func():
		%Sawblade.monitoring = true)

	slowdown_fx.start_slowdown()
	modulate_fx.lights_off(0.4, 0.25).set_trans(Tween.TRANS_SINE)

	(create_tween()
		.tween_property(%Sawblade, ^"global_position:y", -50, 0.25)
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		.as_relative())

	await (create_tween()
		.tween_property(%Sawblade, ^"global_position:x", 60, 1.0 * SlowdownFX.DEFAULT_SCALE)
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
		.finished)

	modulate_fx.lights_on()
	slowdown_fx.end_slowdown()
	$SawbladeClipHack/Sawblade/AudioStreamPlayer.stop()
	%Sawblade.visible = false


func _do_stop() -> void:
		$Stoplight.visible = true
		$Stoplight.play()
		while $Stoplight.frame < 4:
			await $Stoplight.frame_changed
		stop_moving.emit()
		await $Stoplight.animation_finished
		$Stoplight.visible = false


func _do_quadrants() -> void:
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


## lil object to encapsulate messing with Engine.time_scale animatedly
class SlowdownFX:
	const DEFAULT_SCALE: float = 0.3
	const DEFAULT_DURATION_IN: float = 0.2
	const DEFAULT_DURATION_OUT: float = 0.2
	
	var some_node: Node  ## Need something to call "create_tween()" on
	
	func _init(the_node: Node):
		some_node = the_node

	func start_slowdown(
		time_scale: float = DEFAULT_SCALE,
		transition_duration: float = DEFAULT_DURATION_IN
	) -> PropertyTweener:
		return (some_node.create_tween()
			.set_ignore_time_scale()
			.tween_property(Engine, ^"time_scale", time_scale, transition_duration)
			.set_trans(Tween.TRANS_SINE))

	func end_slowdown(
		transition_duration: float = DEFAULT_DURATION_OUT
	) -> PropertyTweener:
		return (some_node.create_tween()
			.set_ignore_time_scale()
			.tween_property(Engine, ^"time_scale", 1.0, transition_duration)
			.set_trans(Tween.TRANS_SINE))


## lil object to encapsulate %CanvasModulate + colors and timings
class ModulateFX:
	const DARK_COLOR: Color = GlobalVariables.COLOR_BG
	const LIGHT_COLOR: Color = Color.WHITE

	var color_modulate: CanvasModulate

	func _init(the_modulate: CanvasModulate):
		color_modulate = the_modulate

	func lights_off(intensity: float = 1.0, duration: float = 0.125) -> PropertyTweener:
		var darker = Color.WHITE.lerp(DARK_COLOR, intensity)
		return (color_modulate.create_tween()
			.set_ignore_time_scale()
			.tween_property(color_modulate, "color", darker, duration)
			.set_trans(Tween.TRANS_BOUNCE))

	func lights_on(duration: float = 0.25) -> PropertyTweener:
		return (color_modulate.create_tween()
			.set_ignore_time_scale()
			.tween_property(color_modulate, "color", LIGHT_COLOR, duration))
