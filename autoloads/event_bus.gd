## EventBus autoload
extends Node

@warning_ignore_start("unused_signal")

# Trap signals
signal trap_started(name: StringName)
signal trap_finished(name: StringName)
signal trap_cooldown()
signal trap_color_picked(blessed_quadrant: Quadrant)

# Ammo signals
signal ammo_picked(ammo_count: int)
signal ammo_used(ammo_count: int)

signal player_killed()

signal game_over(winner: StringName)

@warning_ignore_restore("unused_signal")
