extends TextureRect

signal back_requested

func go_back():
	back_requested.emit()


func _enter_tree() -> void:
	var joypads := Input.get_connected_joypads()
	show_joypad_connection_change(0, 0 in joypads)
	show_joypad_connection_change(1, 1 in joypads)
	Input.joy_connection_changed.connect(show_joypad_connection_change)

func _exit_tree() -> void:
	Input.joy_connection_changed.disconnect(show_joypad_connection_change)


func show_joypad_connection_change(device: int, connected: bool):
	[$P1_tint, $P2_tint][device].visible = not connected


var _dirs := ["up", "down", "left", "right"]
var _traps := ["color", "saw", "stop", "laser"]

func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		go_back()


#region haskell brainrot

	var target_label = $target
	match get_action_label(event):
		target_label:
			# sorry
			var is_target_joy = (
				event is InputEventJoypadMotion
				and [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y].any(func(axis):
					return absf(Input.get_joy_axis(event.device, axis)) > 0.5)
				or _dirs.any(func(dir): return event.get_action_strength("target_" + dir))
			)
			target_label.modulate = Color.GREEN if is_target_joy else Color.WHITE
		var label when label:
			label.modulate = Color.GREEN if event.is_pressed() else Color.WHITE
	accept_event()


func _action_name_tester(action: InputEvent, prefix: String) -> Callable:
	return func(suffix: String):
		return action.is_action(prefix + "_" + suffix)

## Returns the Label for the given InputEvent, if there is a matching one
func get_action_label(action: InputEvent) -> Label:
	if action.is_action("beep_boop"):
		return $beep_boop
	elif action.is_action("throw"):
		return $throw
	elif _dirs.any(_action_name_tester(action, "move")):
		return $move
	elif _dirs.any(_action_name_tester(action, "target")):
		return $target
	var maybe_trap := _traps.filter(_action_name_tester(action, "trap"))
	if not maybe_trap.is_empty():
		return get_node_or_null("trap_" + maybe_trap[0])
	return null

#endregion
