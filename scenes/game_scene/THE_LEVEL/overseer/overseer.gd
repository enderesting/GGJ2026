extends Node2D

@onready var play_area = %PlayArea

#signal ray_shot
signal stop_moving
signal color_picked


func _ready() -> void:
	$Deathray.visible = false
	$Sawblade.visible = false
	$Stoplight.visible = false
	$Colorpicker.visible = false
	
	$Colorpicker/Color1.global_position = play_area.position - play_area.shape.size/4
	$Colorpicker/Color2.global_position = play_area.position - Vector2((-play_area.shape.size.x/4) ,play_area.shape.size.y/4)
	$Colorpicker/Color3.global_position = play_area.position + play_area.shape.size/4
	$Colorpicker/Color4.global_position = play_area.position - Vector2(play_area.shape.size.x/4 ,-(play_area.shape.size.y/4))
	

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
		var picked_color = $Colorpicker.get_children().pick_random()
		
		$Colorpicker.propagate_call("set_visible", [true]) # reset visibility
		
		var blinks := create_tween().set_loops(2) # <- how many times to blink
		blinks.tween_callback($Colorpicker.set_visible.bind(true))
		blinks.tween_interval(0.5)
		blinks.tween_callback($Colorpicker.set_visible.bind(false))
		blinks.tween_interval(0.5)
		await blinks.finished
		
		$Colorpicker.propagate_call("set_visible", [false]) # Hide all children
		$Colorpicker.visible = true                         # except the parent
		picked_color.visible = true                         # and reveal the picked color
		
		color_picked.emit(picked_color.get_index() + 1)
