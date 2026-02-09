## Central place to subscribe and dispatch global game events
## Auto-loaded as "EventBus"
extends Node

@warning_ignore_start("unused_signal")

# Trap signals
signal trap_started(name: StringName)
signal trap_finished(name: StringName)
signal trap_cooldown()
signal trap_color_picked(blessed_quadrant: Quadrant)

# Ammo signals
signal ammo_picked(ammo_count: int)  ## Player picked up ammo
signal ammo_used(ammo_count: int)    ## Player used ammo

signal player_killed()

signal game_over(winner: StringName)

@warning_ignore_restore("unused_signal")

func _ready() -> void:
	var signal_names = get_signal_list().map(func(s): return s.name)
	print_verbose(signal_names)
